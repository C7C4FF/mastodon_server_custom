import { useCallback, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import CloseIcon from '@/material-icons/400-20px/close.svg?react';
import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { DisplayName } from 'mastodon/components/display_name';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { useAppHistory } from 'mastodon/components/router';
import { DialogModal } from 'mastodon/features/ui/components/dialog_modal';
import { useSearchAccounts } from 'mastodon/hooks/useSearchAccounts';
import { useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  title: { id: 'direct.new_conversation', defaultMessage: 'New message' },
  search: {
    id: 'direct.new_conversation.search',
    defaultMessage: 'Search followers and people you follow',
  },
  select: {
    id: 'direct.new_conversation.select',
    defaultMessage: 'Select {name}',
  },
  remove: {
    id: 'direct.new_conversation.remove',
    defaultMessage: 'Remove {name}',
  },
});

const AccountOption: React.FC<{
  accountId: string;
  checked: boolean;
  onToggle: (accountId: string) => void;
}> = ({ accountId, checked, onToggle }) => {
  const intl = useIntl();
  const account = useAppSelector((state) => state.accounts.get(accountId));

  const handleClick = useCallback(() => {
    onToggle(accountId);
  }, [accountId, onToggle]);

  if (!account) {
    return null;
  }

  return (
    <button
      type='button'
      className='new-direct-message-modal__account'
      aria-label={intl.formatMessage(messages.select, {
        name: account.get('display_name') || account.get('username'),
      })}
      aria-pressed={checked}
      onClick={handleClick}
    >
      <Avatar account={account} size={44} />
      <DisplayName account={account} />
      {checked && (
        <span className='new-direct-message-modal__check'>
          <Icon id='check' icon={CheckIcon} />
        </span>
      )}
    </button>
  );
};

export const NewConversationModal: React.FC<{ onClose: () => void }> = ({
  onClose,
}) => {
  const history = useAppHistory();
  const intl = useIntl();
  const relationships = useAppSelector((state) => state.relationships);
  const accountsById = useAppSelector((state) => state.accounts);
  const [query, setQuery] = useState('');
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const { accounts, isLoading, searchAccounts } = useSearchAccounts({
    withRelationships: true,
    withDefaultFollows: query.length === 0,
    withDefaultFollowers: query.length === 0,
  });

  const eligibleAccounts =
    query.length === 0
      ? accounts
      : accounts.filter(({ id }) => {
          const relationship = relationships.get(id);
          return relationship?.following || relationship?.followed_by;
        });
  const isCheckingRelationships =
    query.length > 0 && accounts.some(({ id }) => !relationships.has(id));

  const handleSearch = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setQuery(event.target.value);
      searchAccounts(event.target.value);
    },
    [searchAccounts],
  );

  const handleToggle = useCallback(
    (accountId: string) => {
      setSelectedIds((current) =>
        current.includes(accountId)
          ? current.filter((id) => id !== accountId)
          : [...current, accountId],
      );
    },
    [],
  );

  const handleStart = useCallback(() => {
    history.push('/conversations/new', { directAccountIds: selectedIds });
    onClose();
  }, [history, onClose, selectedIds]);

  const handleRemove = useCallback(
    (event: React.MouseEvent<HTMLButtonElement>) => {
      const accountId = event.currentTarget.dataset.accountId;

      if (accountId) {
        handleToggle(accountId);
      }
    },
    [handleToggle],
  );

  return (
    <DialogModal
      className='new-direct-message-modal'
      title={intl.formatMessage(messages.title)}
      onClose={onClose}
      buttons={
        <Button disabled={selectedIds.length === 0} onClick={handleStart}>
          <FormattedMessage
            id='direct.new_conversation.start'
            defaultMessage='Start conversation ({count})'
            values={{ count: selectedIds.length }}
          />
        </Button>
      }
    >
      <label className='new-direct-message-modal__search'>
        <Icon id='search' icon={SearchIcon} />
        <input
          type='search'
          value={query}
          placeholder={intl.formatMessage(messages.search)}
          aria-label={intl.formatMessage(messages.search)}
          onChange={handleSearch}
        />
      </label>

      {selectedIds.length > 0 && (
        <div className='new-direct-message-modal__selected'>
          {selectedIds.map((id) => {
            const account = accountsById.get(id);

            if (!account) {
              return null;
            }

            const name = account.get('display_name') || account.get('username');

            return (
              <button
                key={id}
                type='button'
                data-account-id={id}
                aria-label={intl.formatMessage(messages.remove, { name })}
                onClick={handleRemove}
              >
                <Avatar account={account} size={20} />
                <span>{name}</span>
                <Icon id='close' icon={CloseIcon} />
              </button>
            );
          })}
        </div>
      )}

      <div className='new-direct-message-modal__accounts'>
        {(isLoading || isCheckingRelationships) &&
        eligibleAccounts.length === 0 ? (
          <LoadingIndicator />
        ) : eligibleAccounts.length === 0 ? (
          <p className='new-direct-message-modal__empty'>
            <FormattedMessage
              id='direct.new_conversation.empty'
              defaultMessage='No matching followers or people you follow.'
            />
          </p>
        ) : (
          eligibleAccounts.map(({ id }) => (
            <AccountOption
              key={id}
              accountId={id}
              checked={selectedIds.includes(id)}
              onToggle={handleToggle}
            />
          ))
        )}
      </div>
    </DialogModal>
  );
};
