import { fromJS } from 'immutable';

import { render, screen } from '@/testing/rendering';

import AttachmentList from '../attachment_list';

it('shows image previews while keeping other attachments as filenames', () => {
  render(
    <AttachmentList
      compact
      preview
      media={fromJS([
        { id: '1', type: 'image', url: '/cat.png', preview_url: '/cat-preview.png', description: 'Cat' },
        { id: '2', type: 'unknown', url: '/notes.txt' },
      ])}
    />,
  );

  expect(screen.getByRole('img', { name: 'Cat' }).getAttribute('src')).toBe('/cat-preview.png');
  expect(screen.getByText('notes.txt')).toBeTruthy();
});
