import { createSelector } from '@reduxjs/toolkit';

import { animated, useSpring } from '@react-spring/web';

import { useAppSelector } from 'mastodon/store';
import type { RootState } from 'mastodon/store';

const selector = createSelector(
  (state: RootState) => state.compose.get('privacy') as string,
  (privacy) => ({
    directMessageWarning: privacy === 'direct',
  }),
);

export const Warning = () => {
  const { directMessageWarning } = useAppSelector(selector);

  if (directMessageWarning) {
    return null;
  }

  return null;
};

export const WarningMessage: React.FC<React.PropsWithChildren> = ({
  children,
}) => {
  const styles = useSpring({
    from: {
      opacity: 0,
      transform: 'scale(0.85, 0.75)',
    },
    to: {
      opacity: 1,
      transform: 'scale(1, 1)',
    },
  });
  return (
    <animated.div className='compose-form__warning' style={styles}>
      {children}
    </animated.div>
  );
};
