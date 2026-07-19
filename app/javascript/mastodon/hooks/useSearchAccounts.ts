import { useCallback, useEffect, useRef, useState } from 'react';

import { useDebouncedCallback } from 'use-debounce';

import { fetchRelationships } from 'mastodon/actions/accounts';
import { importFetchedAccounts } from 'mastodon/actions/importer';
import { apiRequest } from 'mastodon/api';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import { useAppDispatch } from 'mastodon/store';

import { useCurrentAccountId } from './useAccountId';

export function useSearchAccounts({
  onSettled,
  filterResults,
  resetOnInputClear = true,
  withRelationships = false,
  withDefaultFollows = false,
  withDefaultFollowers = false,
}: {
  onSettled?: (value: string) => void;
  filterResults?: (account: ApiAccountJSON) => boolean;
  resetOnInputClear?: boolean;
  withRelationships?: boolean;
  withDefaultFollows?: boolean;
  withDefaultFollowers?: boolean;
} = {}) {
  const dispatch = useAppDispatch();

  const [accounts, setAccounts] = useState<ApiAccountJSON[]>([]);
  const [loadingState, setLoadingState] = useState<
    'idle' | 'loading' | 'error'
  >('idle');

  const searchRequestRef = useRef<AbortController | null>(null);

  const searchAccounts = useDebouncedCallback(
    async (value: string) => {
      if (searchRequestRef.current) {
        searchRequestRef.current.abort();
      }

      if (value.trim().length === 0) {
        onSettled?.('');
        if (resetOnInputClear) {
          setAccounts([]);
        }
        return;
      }

      setLoadingState('loading');

      searchRequestRef.current = new AbortController();

      try {
        const accounts = await apiRequest<ApiAccountJSON[]>(
          'GET',
          'v1/accounts/search',
          {
            signal: searchRequestRef.current.signal,
            params: {
              q: value,
              resolve: true,
            },
          },
        );
        const accountIds = accounts.map((a) => a.id);
        dispatch(importFetchedAccounts(accounts));
        if (withRelationships) {
          dispatch(fetchRelationships(accountIds));
        }
        setAccounts(accounts);
        setLoadingState('idle');
        onSettled?.(value);
      } catch {
        setLoadingState('error');
        onSettled?.(value);
      }
    },
    500,
    { leading: true, trailing: true },
  );

  const startSearch = useCallback(
    (value: string) => {
      void searchAccounts(value);
    },
    [searchAccounts],
  );

  const resetAccounts = useCallback(() => {
    setAccounts([]);
  }, []);

  const currentUserId = useCurrentAccountId();
  const [defaultAccounts, setDefaultAccounts] = useState<
    ApiAccountJSON[] | null
  >(null);

  useEffect(() => {
    if (
      !currentUserId ||
      loadingState !== 'idle' ||
      defaultAccounts !== null ||
      (!withDefaultFollows && !withDefaultFollowers)
    ) {
      return;
    }

    async function doRequest() {
      setLoadingState('loading');
      try {
        const relationships = [
          ...(withDefaultFollows ? ['following'] : []),
          ...(withDefaultFollowers ? ['followers'] : []),
        ];
        const responses = await Promise.all(
          relationships.map((relationship) =>
            apiRequest<ApiAccountJSON[]>(
              'GET',
              `v1/accounts/${currentUserId}/${relationship}`,
              // ponytail: Default suggestions are capped; search covers larger lists.
              { params: { limit: 80 } },
            ),
          ),
        );
        const accounts = [
          ...new Map(
            responses.flat().map((account) => [account.id, account]),
          ).values(),
        ];
        const accountIds = accounts.map((a) => a.id);
        dispatch(importFetchedAccounts(accounts));
        if (withRelationships) {
          dispatch(fetchRelationships(accountIds));
        }
        setDefaultAccounts(accounts);
        setLoadingState('idle');
      } catch {
        setLoadingState('error');
      }
    }
    void doRequest();
  }, [
    currentUserId,
    accounts,
    dispatch,
    filterResults,
    loadingState,
    withRelationships,
    defaultAccounts,
    withDefaultFollows,
    withDefaultFollowers,
  ]);

  const accountsToReturn =
    accounts.length === 0 && (withDefaultFollows || withDefaultFollowers)
      ? (defaultAccounts ?? [])
      : accounts;

  const filteredAccounts = filterResults
    ? accountsToReturn.filter(filterResults)
    : accountsToReturn;

  return {
    searchAccounts: startSearch,
    resetAccounts,
    accounts: filteredAccounts,
    isLoading: loadingState === 'loading',
    isError: loadingState === 'error',
  };
}
