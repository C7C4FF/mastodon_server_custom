import type {
  ApiContextJSON,
  ApiStatusJSON,
} from 'mastodon/api_types/statuses';

import { fetchContext } from '../actions/statuses';
import { TIMELINE_UPDATE } from '../actions/timelines';

import { contextsReducer } from './contexts';

const status = (id: string) =>
  ({ id, in_reply_to_id: null }) as unknown as ApiStatusJSON;

describe('contextsReducer', () => {
  it('builds the direct-message order from the standard context fields', () => {
    const context = {
      ancestors: [status('1')],
      descendants: [status('3')],
    } satisfies ApiContextJSON;

    const state = contextsReducer(
      undefined,
      fetchContext.fulfilled(
        { context, refresh: null, prefetchOnly: false },
        'request-id',
        { statusId: '2' },
      ),
    );

    expect(state.directMessages['2']).toEqual(['1', '2', '3']);
  });

  it('adds a streamed direct message to its open thread', () => {
    const context = {
      ancestors: [status('1')],
      descendants: [status('3')],
    } satisfies ApiContextJSON;
    const initialState = contextsReducer(
      undefined,
      fetchContext.fulfilled(
        { context, refresh: null, prefetchOnly: false },
        'request-id',
        { statusId: '2' },
      ),
    );

    const state = contextsReducer(initialState, {
      type: TIMELINE_UPDATE,
      timeline: 'direct',
      status: {
        id: '4',
        in_reply_to_id: '3',
        visibility: 'direct',
      } as ApiStatusJSON,
      usePendingItems: false,
    });

    expect(state.directMessages['2']).toEqual(['1', '2', '3', '4']);
  });
});
