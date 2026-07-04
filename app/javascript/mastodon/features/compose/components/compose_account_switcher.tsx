import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import { changeComposeAccount } from 'mastodon/actions/compose';
import api from 'mastodon/api';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import { Avatar } from 'mastodon/components/avatar';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  changeAccount: {
    id: 'compose_account.change',
    defaultMessage: '작성 계정 변경',
  },
  lockedByMedia: {
    id: 'compose_account.locked_by_media',
    defaultMessage: '첨부된 미디어가 있으면 작성 계정을 바꿀 수 없습니다',
  },
  lockedByEdit: {
    id: 'compose_account.locked_by_edit',
    defaultMessage: '글을 수정하는 동안에는 작성 계정을 바꿀 수 없습니다',
  },
});

interface AccountSwitcherState {
  current_account_id: string;
  accounts: ApiAccountJSON[];
}

const accountDisplayName = (account: ApiAccountJSON) =>
  account.display_name.trim().length > 0 ? account.display_name : account.username;

export const ComposeAccountSwitcher: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const overlayTargetRef = useRef<HTMLDivElement | null>(null);
  const overlayRef = useRef<HTMLDivElement | null>(null);
  const [accountState, setAccountState] = useState<AccountSwitcherState | null>(
    null,
  );
  const [isOpen, setIsOpen] = useState(false);
  const [loading, setLoading] = useState(true);

  const selectedAccountId = useAppSelector(
    (state) => state.compose.get('account_id') as string | null,
  );
  const mediaAttachmentCount = useAppSelector((state) => {
    const mediaAttachments = state.compose.get('media_attachments') as
      | { size: number }
      | undefined;

    return mediaAttachments?.size ?? 0;
  });
  const isUploading = useAppSelector(
    (state) =>
      Boolean(state.compose.get('is_uploading')) ||
      Boolean(state.compose.get('is_changing_upload')),
  );
  const isEditing = useAppSelector((state) => state.compose.get('id') !== null);

  const loadAccounts = useCallback(() => {
    return api(false)
      .get<AccountSwitcherState>('/auth/account_switcher.json')
      .then(({ data }) => {
        setAccountState(data);
      })
      .catch(() => {
        setAccountState({ current_account_id: '', accounts: [] });
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  useEffect(() => {
    void loadAccounts();
  }, [loadAccounts]);

  const accounts = useMemo(() => accountState?.accounts ?? [], [accountState]);
  const explicitlySelectedAccount = useMemo(
    () => accounts.find((account) => account.id === selectedAccountId),
    [accounts, selectedAccountId],
  );
  const selectedAccount = useMemo(
    () =>
      explicitlySelectedAccount ??
      accounts.find((account) => account.id === accountState?.current_account_id) ??
      accounts.at(0),
    [accountState?.current_account_id, accounts, explicitlySelectedAccount],
  );

  useEffect(() => {
    if (!accountState || accounts.length === 0) {
      return;
    }

    if (selectedAccountId && !explicitlySelectedAccount) {
      dispatch(changeComposeAccount(accountState.current_account_id));
    }
  }, [
    accountState,
    accounts.length,
    dispatch,
    explicitlySelectedAccount,
    selectedAccountId,
  ]);

  const handleClose = useCallback(() => {
    setIsOpen(false);
  }, []);

  const handleToggle = useCallback(() => {
    if (!isOpen) {
      setLoading(true);
      void loadAccounts();
    }

    setIsOpen(!isOpen);
  }, [isOpen, loadAccounts]);

  const handleAccountSelect = useCallback(
    (event: React.MouseEvent<HTMLButtonElement>) => {
      const { accountId } = event.currentTarget.dataset;

      if (accountId) {
        dispatch(changeComposeAccount(accountId));
      }

      handleClose();
    },
    [dispatch, handleClose],
  );

  useEffect(() => {
    if (!isOpen) {
      return;
    }

    const handleDocumentPointer = (event: MouseEvent | TouchEvent) => {
      const target = event.target;

      if (!(target instanceof Node)) {
        return;
      }

      if (
        overlayTargetRef.current?.contains(target) ||
        overlayRef.current?.contains(target)
      ) {
        return;
      }

      handleClose();
    };

    const handleDocumentKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        handleClose();
      }
    };

    document.addEventListener('mousedown', handleDocumentPointer, true);
    document.addEventListener('touchend', handleDocumentPointer, true);
    document.addEventListener('keydown', handleDocumentKeyDown);

    return () => {
      document.removeEventListener('mousedown', handleDocumentPointer, true);
      document.removeEventListener('touchend', handleDocumentPointer, true);
      document.removeEventListener('keydown', handleDocumentKeyDown);
    };
  }, [handleClose, isOpen]);

  if (loading && !accountState) {
    return null;
  }

  if (accounts.length <= 1 || !selectedAccount) {
    return null;
  }

  const locked = isEditing || mediaAttachmentCount > 0 || isUploading;
  const title = isEditing
    ? intl.formatMessage(messages.lockedByEdit)
    : mediaAttachmentCount > 0 || isUploading
      ? intl.formatMessage(messages.lockedByMedia)
      : intl.formatMessage(messages.changeAccount);

  return (
    <div className='compose-account-switcher' ref={overlayTargetRef}>
      <button
        type='button'
        title={title}
        aria-expanded={isOpen}
        onClick={handleToggle}
        disabled={locked}
        className={classNames('dropdown-button', 'compose-account-switcher__button', {
          active: isOpen,
        })}
      >
        <Avatar account={selectedAccount} size={18} />
        <span className='dropdown-button__label'>
          {accountDisplayName(selectedAccount)}
        </span>
      </button>

      <Overlay
        show={isOpen}
        offset={[5, 5]}
        placement='bottom-start'
        flip
        target={overlayTargetRef}
        popperConfig={{ strategy: 'fixed' }}
      >
        {({ props, placement }) => (
          <div {...props}>
            <div
              ref={overlayRef}
              className={`dropdown-animation compose-account-switcher__dropdown ${placement}`}
            >
              {accounts.map((account) => (
                <button
                  type='button'
                  className={classNames('compose-account-switcher__option', {
                    active: account.id === selectedAccount.id,
                  })}
                  key={account.id}
                  data-account-id={account.id}
                  aria-current={
                    account.id === selectedAccount.id ? 'true' : undefined
                  }
                  onClick={handleAccountSelect}
                >
                  <Avatar account={account} size={32} />
                  <span className='compose-account-switcher__option-copy'>
                    <strong>{accountDisplayName(account)}</strong>
                    <span>@{account.acct}</span>
                  </span>
                </button>
              ))}
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
};
