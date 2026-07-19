import { useCallback, useMemo, useRef, useState } from 'react';

import PropTypes from 'prop-types';
import { defineMessages, useIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { useDispatch } from 'react-redux';

import CloseIcon from '@/material-icons/400-20px/close.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-20px/photo_library.svg?react';
import { IconButton } from '@/mastodon/components/icon_button';
import { showAlertForError } from 'mastodon/actions/alerts';
import { importFetchedStatus } from 'mastodon/actions/importer';
import { fetchStatus } from 'mastodon/actions/statuses';
import api from 'mastodon/api';
import { useIdentity } from 'mastodon/identity_context';

const messages = defineMessages({
  placeholder: { id: 'direct_reply.placeholder', defaultMessage: 'Write a message' },
  removeImage: { id: 'direct_reply.remove_image', defaultMessage: 'Remove image' },
  send: { id: 'direct_reply.send', defaultMessage: 'Send' },
  uploadImage: { id: 'direct_reply.upload_image', defaultMessage: 'Add an image' },
});

const getMentionAcct = mention => mention.get('acct') || mention.get('username');

export const getDirectParticipants = (state, statusIds, accountId) => {
  const participants = new Map();

  statusIds.forEach(id => {
    const status = state.getIn(['statuses', id]);
    const authorId = status?.get('account');

    if (authorId && authorId !== accountId) {
      participants.set(authorId, state.getIn(['accounts', authorId]));
    }

    status?.get('mentions')?.forEach(mention => {
      const mentionId = mention.get('id');

      if (mentionId && mentionId !== accountId) {
        participants.set(mentionId, state.getIn(['accounts', mentionId]) || mention);
      }
    });
  });

  return Array.from(participants.values()).filter(Boolean);
};

export const buildDirectMessageRows = (statusIds, dates, formatDate, authors = {}) => {
  let previousDate;
  let previousAuthor = null;

  return statusIds.map((id, index) => {
    const createdAt = dates[id];
    const formattedDate = createdAt ? formatDate(createdAt) : null;
    const date = formattedDate && formattedDate !== previousDate ? formattedDate : null;
    const author = authors[id];
    const nextId = statusIds[index + 1];
    const showAvatar = Boolean(date || author !== previousAuthor);
    const showTime = !nextId || author !== authors[nextId] || createdAt?.slice(0, 16) !== dates[nextId]?.slice(0, 16);

    if (formattedDate) {
      previousDate = formattedDate;
    }

    previousAuthor = author;

    return { id, createdAt, date, showAvatar, showTime };
  });
};

export const DirectReplyComposer = ({ status }) => {
  const intl = useIntl();
  const dispatch = useDispatch();
  const { accountId } = useIdentity();
  const fileInputRef = useRef(null);
  const [text, setText] = useState('');
  const [media, setMedia] = useState(null);
  const [isUploading, setIsUploading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const recipients = useMemo(() => {
    const seen = new Set();
    const result = [];

    const add = (id, acct) => {
      if (!acct || id === accountId || seen.has(acct)) {
        return;
      }

      seen.add(acct);
      result.push({ id, acct });
    };

    add(status.getIn(['account', 'id']), status.getIn(['account', 'acct']));

    status.get('mentions')?.forEach(mention => {
      add(mention.get('id'), getMentionAcct(mention));
    });

    return result;
  }, [accountId, status]);

  const handleChange = useCallback(e => {
    setText(e.target.value);
  }, []);

  const handleUploadClick = useCallback(() => {
    fileInputRef.current?.click();
  }, []);

  const handleSelectImage = useCallback(e => {
    const file = e.target.files[0];
    e.target.value = '';

    if (!file) {
      return;
    }

    const data = new FormData();
    data.append('file', file);

    if (accountId) {
      data.append('account_id', accountId);
    }

    setIsUploading(true);

    api().post('/api/v1/media', data).then(response => {
      setMedia(response.data);
    }).catch(error => {
      dispatch(showAlertForError(error));
    }).finally(() => {
      setIsUploading(false);
    });
  }, [accountId, dispatch]);

  const handleSubmit = useCallback(() => {
    const trimmed = text.trim();

    if ((!trimmed && !media) || isSubmitting || isUploading) {
      return;
    }

    const mentionPrefix = recipients.map(({ acct }) => `@${acct}`).join(' ');
    const body = mentionPrefix ? `${mentionPrefix} ${trimmed}` : trimmed;

    setIsSubmitting(true);

    api().post('/api/v1/statuses', {
      status: body,
      visibility: 'direct',
      in_reply_to_id: status.get('id'),
      media_ids: media ? [media.id] : [],
      quote_approval_policy: 'nobody',
      allowed_mentions: recipients.map(({ id }) => id).filter(Boolean),
    }).then(response => {
      dispatch(importFetchedStatus(response.data));
      dispatch(fetchStatus(status.get('id'), { forceFetch: true }));
      setText('');
      setMedia(null);
    }).catch(error => {
      dispatch(showAlertForError(error));
    }).finally(() => {
      setIsSubmitting(false);
    });
  }, [dispatch, isSubmitting, isUploading, media, recipients, status, text]);

  const handleRemoveImage = useCallback(() => {
    setMedia(null);
  }, []);

  const handleKeyDown = useCallback(e => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  }, [handleSubmit]);

  return (
    <div className='direct-reply-composer'>
      <IconButton
        className='direct-reply-composer__upload-button'
        title={intl.formatMessage(messages.uploadImage)}
        icon='paperclip'
        iconComponent={PhotoLibraryIcon}
        active={Boolean(media)}
        disabled={isUploading || isSubmitting}
        onClick={handleUploadClick}
      />

      <input
        ref={fileInputRef}
        type='file'
        accept='image/*'
        onChange={handleSelectImage}
        disabled={isUploading || isSubmitting}
        hidden
      />

      <div className='direct-reply-composer__input'>
        {media && (
          <div className='direct-reply-composer__preview'>
            <img src={media.preview_url || media.url} alt='' />
            <IconButton
              className='direct-reply-composer__preview-remove'
              title={intl.formatMessage(messages.removeImage)}
              icon='times'
              iconComponent={CloseIcon}
              onClick={handleRemoveImage}
            />
          </div>
        )}

        <textarea
          className='direct-reply-composer__textarea'
          value={text}
          onChange={handleChange}
          onKeyDown={handleKeyDown}
          placeholder={intl.formatMessage(messages.placeholder)}
          rows={1}
        />
      </div>

      <button
        className='direct-reply-composer__button'
        type='button'
        disabled={(text.trim().length === 0 && !media) || isUploading || isSubmitting}
        onClick={handleSubmit}
      >
        {intl.formatMessage(messages.send)}
      </button>
    </div>
  );
};

DirectReplyComposer.propTypes = {
  status: ImmutablePropTypes.map.isRequired,
};
