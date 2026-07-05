/* global beforeEach, describe, expect, it, vi */

import { fromJS } from 'immutable';

const loadComposeReducer = async () => {
  document.body.innerHTML =
    '<script id="initial-state" type="application/json">{"meta":{"me":"1"},"languages":[],"compose":{}}</script>';
  vi.resetModules();

  return import('./compose');
};

const replyStatus = fromJS({
  id: '100',
  account: {
    id: '1',
    acct: 'C7C4FF',
  },
  mentions: [],
  spoiler_text: '',
  visibility: 'public',
  language: null,
});

describe('composeReducer', () => {
  beforeEach(() => {
    document.body.innerHTML = '';
  });

  it('prefills the replied-to account when replying as a switched account', async () => {
    const { composeReducer } = await loadComposeReducer();
    const state = composeReducer(undefined, { type: '@@INIT' }).set(
      'account_id',
      '2',
    );

    const nextState = composeReducer(state, {
      type: 'COMPOSE_REPLY',
      status: replyStatus,
    });

    expect(nextState.get('text')).toBe('@C7C4FF ');
  });

  it('refreshes reply mentions when switching accounts inside a reply', async () => {
    const { composeReducer } = await loadComposeReducer();
    const state = composeReducer(undefined, { type: '@@INIT' });
    const replyState = composeReducer(state, {
      type: 'COMPOSE_REPLY',
      status: replyStatus,
    });

    const switchedState = composeReducer(replyState, {
      type: 'COMPOSE_ACCOUNT_CHANGE',
      accountId: '2',
      status: replyStatus,
    });

    expect(replyState.get('text')).toBe('');
    expect(switchedState.get('text')).toBe('@C7C4FF ');
  });
});
