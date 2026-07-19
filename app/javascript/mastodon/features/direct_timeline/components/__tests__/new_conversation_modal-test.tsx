import { IntlProvider } from 'react-intl';

import { Map as ImmutableMap, fromJS } from 'immutable';

import { fireEvent, render, screen } from '@testing-library/react';
import { vi } from 'vitest';

import { FocusTargetProvider } from '@/mastodon/components/navigation_focus_target';
import { browserHistory, Router } from '@/mastodon/components/router';
import { useSearchAccounts } from 'mastodon/hooks/useSearchAccounts';
import type { RootState } from 'mastodon/store';
import { useAppSelector } from 'mastodon/store';

import { NewConversationModal } from '../new_conversation_modal';

vi.mock('mastodon/hooks/useSearchAccounts', () => ({
  useSearchAccounts: vi.fn(),
}));

vi.mock('mastodon/store', () => ({
  useAppSelector: vi.fn(),
}));

vi.mock('mastodon/components/avatar', () => ({
  Avatar: () => <span />,
}));

vi.mock('mastodon/components/display_name', () => ({
  DisplayName: ({ account }: { account: ImmutableMap<string, string> }) => (
    <span>{account.get('display_name')}</span>
  ),
}));

describe('<NewConversationModal />', () => {
  const onClose = vi.fn();
  const searchAccounts = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    browserHistory.replace('/');
    vi.mocked(useSearchAccounts).mockImplementation(
      ({ withDefaultFollows } = {}) =>
        ({
          accounts: withDefaultFollows
            ? [
                { id: 'following', display_name: 'Following' },
                { id: 'follower', display_name: 'Follower' },
              ]
            : [
                { id: 'following', display_name: 'Following' },
                { id: 'follower', display_name: 'Follower' },
                { id: 'stranger', display_name: 'Stranger' },
              ],
          isLoading: false,
          isError: false,
          searchAccounts,
          resetAccounts: vi.fn(),
        }) as unknown as ReturnType<typeof useSearchAccounts>,
    );
    vi.mocked(useAppSelector).mockImplementation(
      (selector: (state: RootState) => unknown) =>
        selector({
          accounts: fromJS({
            following: { display_name: 'Following' },
            follower: { display_name: 'Follower' },
            stranger: { display_name: 'Stranger' },
          }),
          relationships: ImmutableMap({
            following: { following: true, followed_by: false },
            follower: { following: false, followed_by: true },
            stranger: { following: false, followed_by: false },
          }),
        } as unknown as RootState),
    );
  });

  it('shows followers and following, then starts a multi-user conversation', () => {
    render(
      <Router>
        <FocusTargetProvider>
          <IntlProvider locale='en'>
            <NewConversationModal onClose={onClose} />
          </IntlProvider>
        </FocusTargetProvider>
      </Router>,
    );

    expect(screen.getByText('Following')).not.toBeNull();
    expect(screen.getByText('Follower')).not.toBeNull();
    expect(useSearchAccounts).toHaveBeenLastCalledWith(
      expect.objectContaining({
        withDefaultFollows: true,
        withDefaultFollowers: true,
      }),
    );

    fireEvent.change(screen.getByRole('searchbox'), {
      target: { value: 'user' },
    });

    expect(screen.queryByText('Stranger')).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: 'Select Following' }));
    fireEvent.click(screen.getByRole('button', { name: 'Select Follower' }));

    expect(
      screen.getByRole('button', { name: 'Remove Following' }),
    ).not.toBeNull();
    expect(
      screen.getByRole('button', { name: 'Remove Follower' }),
    ).not.toBeNull();
    expect(
      screen
        .getByRole('button', { name: 'Select Following' })
        .getAttribute('aria-pressed'),
    ).toBe('true');

    fireEvent.click(
      screen.getByRole('button', { name: 'Start conversation (2)' }),
    );

    expect(browserHistory.location.pathname).toContain('/conversations/new');
    expect(browserHistory.location.state?.directAccountIds).toEqual([
      'following',
      'follower',
    ]);
    expect(onClose).toHaveBeenCalled();
  });
});
