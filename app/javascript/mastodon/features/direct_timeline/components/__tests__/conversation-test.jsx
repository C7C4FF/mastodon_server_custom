import { stripLeadingMentions } from '../conversation';

it('removes leading recipient mentions and their whitespace', () => {
  const content = '<p><span class="h-card">@alice</span> <span class="h-card">@bob</span> message <span class="h-card">@carol</span></p>';

  expect(stripLeadingMentions(content)).toBe('<p>message <span class="h-card">@carol</span></p>');
});
