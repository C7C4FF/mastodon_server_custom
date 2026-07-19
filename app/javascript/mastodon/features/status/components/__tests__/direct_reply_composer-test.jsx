import { IntlProvider } from 'react-intl';

import { List, Map, fromJS } from 'immutable';

import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { vi } from 'vitest';

import { buildDirectMessageRows, DirectReplyComposer, getDirectParticipants } from '../direct_reply_composer';

const dispatch = vi.fn();
const post = vi.fn();

vi.mock('react-redux', async importOriginal => {
  const actual = await importOriginal();
  const useDispatch = () => dispatch;
  useDispatch.withTypes = () => useDispatch;

  return { ...actual, useDispatch };
});

vi.mock('mastodon/api', () => ({
  default: () => ({ post }),
}));

vi.mock('mastodon/identity_context', () => ({
  useIdentity: () => ({ accountId: '1' }),
}));

describe('<DirectReplyComposer />', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('collects unique direct-message participants except the signed-in account', () => {
    const state = fromJS({
      accounts: {
        '2': { id: '2', username: 'friend' },
        '3': { id: '3', username: 'guest' },
      },
      statuses: {
        'status-1': {
          account: '1',
          mentions: [{ id: '2', username: 'friend' }],
        },
        'status-2': {
          account: '2',
          mentions: [
            { id: '1', username: 'me' },
            { id: '3', username: 'guest' },
          ],
        },
      },
    });

    expect(getDirectParticipants(state, ['status-1', 'status-2'], '1').map(account => account.get('id'))).toEqual(['2', '3']);
  });

  it('adds a date only to the first direct message of each day', () => {
    const rows = buildDirectMessageRows(
      ['status-1', 'status-2', 'status-3', 'status-4'],
      {
        'status-1': '2026-07-19T10:00:00Z',
        'status-2': '2026-07-19T10:00:59Z',
        'status-3': '2026-07-19T10:00:59Z',
        'status-4': '2026-07-20T10:00:00Z',
      },
      timestamp => timestamp.slice(0, 10),
      {
        'status-1': 'account-1',
        'status-2': 'account-1',
        'status-3': 'account-2',
        'status-4': 'account-2',
      },
    );

    expect(rows.map(row => row.date)).toEqual(['2026-07-19', null, null, '2026-07-20']);
    expect(rows.map(row => row.showAvatar)).toEqual([true, false, true, true]);
    expect(rows.map(row => row.showTime)).toEqual([false, true, true, true]);
  });

  it('previews, removes, and includes an image in the direct reply', async () => {
    post
      .mockResolvedValueOnce({ data: { id: 'media-1', preview_url: '/media-1.png' } })
      .mockResolvedValueOnce({ data: { id: 'media-1', preview_url: '/media-1.png' } })
      .mockResolvedValueOnce({ data: { id: 'reply-1' } });

    const status = Map({
      id: 'status-1',
      account: Map({ id: '2', acct: 'friend' }),
      mentions: List(),
    });

    const { container } = render(
      <IntlProvider locale='en'>
        <DirectReplyComposer status={status} />
      </IntlProvider>,
    );

    const composer = container.querySelector('.direct-reply-composer');
    const input = container.querySelector('input[type="file"]');

    expect(composer.firstElementChild.classList.contains('direct-reply-composer__upload-button')).toBe(true);
    expect(input.getAttribute('accept')).toBe('image/*');

    fireEvent.change(input, {
      target: { files: [new File(['image'], 'photo.png', { type: 'image/png' })] },
    });

    await waitFor(() => {
      expect(post).toHaveBeenCalledWith('/api/v1/media', expect.any(FormData));
    });

    await waitFor(() => {
      expect(container.querySelector('.direct-reply-composer__preview img')?.getAttribute('src')).toBe('/media-1.png');
    });

    fireEvent.click(screen.getByRole('button', { name: 'Remove image' }));
    expect(container.querySelector('.direct-reply-composer__preview')).toBeNull();

    fireEvent.change(input, {
      target: { files: [new File(['image'], 'photo.png', { type: 'image/png' })] },
    });

    await waitFor(() => {
      expect(post).toHaveBeenCalledTimes(2);
    });

    fireEvent.click(screen.getByRole('button', { name: 'Send' }));

    await waitFor(() => {
      expect(post).toHaveBeenCalledWith('/api/v1/statuses', expect.objectContaining({
        media_ids: ['media-1'],
      }));
    });
  });
});
