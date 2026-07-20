import { render, screen } from '@/testing/rendering';
import { accountFactoryState } from '@/testing/factories';

import { LinkedDisplayName } from '../display_name';

it('shows an anonymized account without its handle or profile link', () => {
  const account = accountFactoryState({
    acct: 'deleted',
    display_name: '탈퇴한 사용자',
    suspended: true,
    username: 'deleted',
  });

  render(<LinkedDisplayName displayProps={{ account }} />);

  expect(screen.getByText('탈퇴한 사용자')).toBeTruthy();
  expect(screen.queryByText('@deleted')).toBeNull();
  expect(screen.queryByRole('link')).toBeNull();
});
