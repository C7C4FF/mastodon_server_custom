import { unmountNotifications } from 'mastodon/actions/notification_groups';

import { notificationGroupsReducer } from './notification_groups';

describe('notificationGroupsReducer', () => {
  it('commits the read marker before the visible notification list unmounts', () => {
    const initialState = notificationGroupsReducer(undefined, { type: 'init' });
    const state = notificationGroupsReducer(
      {
        ...initialState,
        scrolledToTop: true,
        lastReadId: '2',
        readMarkerId: '1',
        mounted: 1,
      },
      unmountNotifications(),
    );

    expect(state.readMarkerId).toBe('2');
    expect(state.mounted).toBe(0);
  });
});
