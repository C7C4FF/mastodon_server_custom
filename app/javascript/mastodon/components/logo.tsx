import classNames from 'classnames';
import { useEffect, useState } from 'react';

import fallbackLogo from '@/images/c7c4ff_logo_icon.png';

import {
  logo as customLogo,
  logoDark,
  logoLight,
} from 'mastodon/initial_state';

const getThemeLogo = () =>
  document.documentElement.dataset.colorScheme === 'light'
    ? (logoLight ?? customLogo ?? logoDark ?? fallbackLogo)
    : (logoDark ?? customLogo ?? logoLight ?? fallbackLogo);

const useThemeLogo = () => {
  const [logo, setLogo] = useState(getThemeLogo);

  useEffect(() => {
    const updateLogo = () => {
      setLogo(getThemeLogo());
    };

    updateLogo();

    const observer = new MutationObserver(updateLogo);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-color-scheme'],
    });

    return () => {
      observer.disconnect();
    };
  }, []);

  return logo;
};

export const WordmarkLogo: React.FC = () => {
  const logo = useThemeLogo();

  return (
    <img
      src={logo}
      alt='C7C4FF'
      className='logo logo--wordmark logo--c7c4ff'
    />
  );
};

export const IconLogo: React.FC<{ className?: string }> = ({ className }) => {
  const logo = useThemeLogo();

  return (
    <img
      src={logo}
      alt='C7C4FF'
      className={classNames('logo logo--icon logo--c7c4ff', className)}
    />
  );
};

export const SymbolLogo: React.FC = () => {
  const logo = useThemeLogo();

  return (
    <img src={logo} alt='C7C4FF' className='logo logo--icon logo--c7c4ff' />
  );
};
