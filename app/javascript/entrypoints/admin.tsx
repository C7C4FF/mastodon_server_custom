import { createRoot } from 'react-dom/client';

import { decode, ValidationError } from 'blurhash';
import { on } from 'delegated-events';

import ready from '../mastodon/ready';

const setAnnouncementEndsAttributes = (target: HTMLInputElement) => {
  const valid = target.value && target.validity.valid;
  const element = document.querySelector<HTMLInputElement>(
    'input[type="datetime-local"]#announcement_ends_at',
  );

  if (!element) return;

  if (valid) {
    element.classList.remove('optional');
    element.required = true;
    element.min = target.value;
  } else {
    element.classList.add('optional');
    element.removeAttribute('required');
    element.removeAttribute('min');
  }
};

const normalizeHexColor = (value: string) => {
  const trimmedValue = value.trim();
  const normalizedValue = trimmedValue.startsWith('#')
    ? trimmedValue
    : `#${trimmedValue}`;

  return /^#[0-9a-fA-F]{6}$/.test(normalizedValue)
    ? normalizedValue.toLowerCase()
    : null;
};

const findBrandingColorInputs = (target: Element) => {
  const row = target.closest('[data-branding-color-row]');

  if (!row) return {};

  return {
    picker: row.querySelector<HTMLInputElement>('[data-branding-color-picker]'),
    hex: row.querySelector<HTMLInputElement>('[data-branding-color-hex]'),
  };
};

const restoreBrandingSavedColorValues = () => {
  document
    .querySelectorAll<HTMLInputElement>('[data-branding-saved-value]')
    .forEach((input) => {
      const savedValue = input.dataset.brandingSavedValue;

      if (!savedValue) return;

      input.value = savedValue;
      input.defaultValue = savedValue;
      updateBrandingPreviewVariable(input);
    });
};

const updateBrandingPreviewVariable = (target: HTMLInputElement) => {
  const previewVariable = target.dataset.brandingPreviewVar;
  const preview = document.querySelector<HTMLElement>('.branding-assets-preview');

  if (!previewVariable || !preview) return;

  if (target.dataset.brandingPreviewTransform === 'opacity') {
    const value = Number.parseInt(target.value, 10);

    if (Number.isNaN(value)) return;

    preview.style.setProperty(
      previewVariable,
      String(Math.min(Math.max(value, 0), 100) / 100),
    );
    return;
  }

  const color = normalizeHexColor(target.value);

  if (color) preview.style.setProperty(previewVariable, color);
};

const originalPreviewVariableKey = (previewVariable: string) =>
  `brandingPreviewOriginal${previewVariable.replace(/[^a-zA-Z0-9]/g, '_')}`;

const findBrandingFileClearButton = (target: Element) =>
  target
    .closest('.fields-group')
    ?.querySelector<HTMLButtonElement>('[data-branding-file-clear]');

const updateBrandingPreviewLogo = (target: HTMLInputElement, file: File) => {
  const logo = document.querySelector<HTMLImageElement>(
    '[data-branding-preview-logo-target]',
  );

  if (!logo) return;

  if (target.dataset.brandingPreviewLogoObjectUrl) {
    URL.revokeObjectURL(target.dataset.brandingPreviewLogoObjectUrl);
  }

  const objectUrl = URL.createObjectURL(file);
  target.dataset.brandingPreviewLogoObjectUrl = objectUrl;
  logo.src = objectUrl;
};

const updateBrandingPreviewLogoForScheme = (scheme: string) => {
  const logo = document.querySelector<HTMLImageElement>(
    '[data-branding-preview-logo-target]',
  );

  if (!logo) return;

  const objectUrl = document.querySelector<HTMLInputElement>(
    '[data-branding-preview-logo-object-url]',
  )?.dataset.brandingPreviewLogoObjectUrl;

  if (objectUrl) {
    logo.src = objectUrl;
    return;
  }

  const nextSrc =
    scheme === 'dark'
      ? logo.dataset.brandingPreviewLogoDark
      : logo.dataset.brandingPreviewLogoLight;

  if (nextSrc) {
    logo.src = nextSrc;
  } else if (logo.dataset.brandingPreviewOriginalSrc) {
    logo.src = logo.dataset.brandingPreviewOriginalSrc;
  }
};

const restoreBrandingPreviewLogo = () => {
  const selectedScheme =
    document.querySelector<HTMLInputElement>(
      '[data-branding-preview-scheme]:checked',
    )?.value ?? 'light';

  updateBrandingPreviewLogoForScheme(selectedScheme);
};

const updateBrandingPreviewBackground = (
  target: HTMLInputElement,
  file: File,
) => {
  const preview = document.querySelector<HTMLElement>('.branding-assets-preview');
  const previewVariables = target.dataset.brandingPreviewImageVars
    ?.split(/\s+/)
    .filter(Boolean);

  if (!preview || !previewVariables?.length) return;

  if (target.dataset.brandingPreviewImageObjectUrl) {
    URL.revokeObjectURL(target.dataset.brandingPreviewImageObjectUrl);
  }

  const objectUrl = URL.createObjectURL(file);
  target.dataset.brandingPreviewImageObjectUrl = objectUrl;

  previewVariables.forEach((previewVariable) => {
    const originalKey = originalPreviewVariableKey(previewVariable);

    if (!(originalKey in preview.dataset)) {
      preview.dataset[originalKey] =
        preview.style.getPropertyValue(previewVariable);
    }

    preview.style.setProperty(previewVariable, `url("${objectUrl}")`);
  });
};

const restoreBrandingPreviewBackground = (target: HTMLInputElement) => {
  const preview = document.querySelector<HTMLElement>('.branding-assets-preview');
  const previewVariables = target.dataset.brandingPreviewImageVars
    ?.split(/\s+/)
    .filter(Boolean);

  if (!preview || !previewVariables?.length) return;

  if (target.dataset.brandingPreviewImageObjectUrl) {
    URL.revokeObjectURL(target.dataset.brandingPreviewImageObjectUrl);
    delete target.dataset.brandingPreviewImageObjectUrl;
  }

  previewVariables.forEach((previewVariable) => {
    const originalKey = originalPreviewVariableKey(previewVariable);
    const originalValue = preview.dataset[originalKey];

    if (originalValue) {
      preview.style.setProperty(previewVariable, originalValue);
    } else {
      preview.style.removeProperty(previewVariable);
    }
  });
};

on('input', '[data-branding-color-picker]', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  const { hex } = findBrandingColorInputs(target);

  if (hex) hex.value = target.value.toLowerCase();

  updateBrandingPreviewVariable(target);
});

on('input', '[data-branding-color-hex]', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  const color = normalizeHexColor(target.value);
  const { picker } = findBrandingColorInputs(target);

  if (color && picker) picker.value = color;

  updateBrandingPreviewVariable(target);
});

on('change', '[data-branding-color-hex]', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  const color = normalizeHexColor(target.value);

  if (color) target.value = color;
});

on('input', '[data-branding-preview-var]', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  updateBrandingPreviewVariable(target);
});

on('change', '[data-branding-preview-scheme]', ({ target }) => {
  if (!(target instanceof HTMLInputElement) || !target.checked) return;

  const preview = document.querySelector<HTMLElement>(
    '[data-branding-preview-root]',
  );

  if (preview) preview.dataset.previewScheme = target.value;

  updateBrandingPreviewLogoForScheme(target.value);
});

on('change', '[data-branding-file-input]', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  const file = target.files?.[0];
  const clearButton = findBrandingFileClearButton(target);

  if (clearButton) clearButton.hidden = !file;

  if (!file) return;

  if (target.dataset.brandingPreviewLogoInput)
    updateBrandingPreviewLogo(target, file);

  if (target.dataset.brandingPreviewImageVars)
    updateBrandingPreviewBackground(target, file);
});

on('click', '[data-branding-file-clear]', ({ target }) => {
  if (!(target instanceof HTMLButtonElement)) return;

  const input = target
    .closest('.fields-group')
    ?.querySelector<HTMLInputElement>('[data-branding-file-input]');

  if (!input) return;

  input.value = '';
  target.hidden = true;

  if (input.dataset.brandingPreviewLogoObjectUrl) {
    URL.revokeObjectURL(input.dataset.brandingPreviewLogoObjectUrl);
    delete input.dataset.brandingPreviewLogoObjectUrl;
  }

  if (input.dataset.brandingPreviewLogoInput) restoreBrandingPreviewLogo();
  if (input.dataset.brandingPreviewImageVars)
    restoreBrandingPreviewBackground(input);
});

on(
  'change',
  'input[type="datetime-local"]#announcement_starts_at',
  ({ target }) => {
    if (target instanceof HTMLInputElement)
      setAnnouncementEndsAttributes(target);
  },
);

const batchCheckboxClassName = '.batch-checkbox input[type="checkbox"]';

const showSelectAll = () => {
  const selectAllMatchingElement = document.querySelector(
    '.batch-table__select-all',
  );
  selectAllMatchingElement?.classList.add('active');
};

const hideSelectAll = () => {
  const selectAllMatchingElement = document.querySelector(
    '.batch-table__select-all',
  );
  const hiddenField = document.querySelector<HTMLInputElement>(
    'input#select_all_matching',
  );
  const selectedMsg = document.querySelector(
    '.batch-table__select-all .selected',
  );
  const notSelectedMsg = document.querySelector(
    '.batch-table__select-all .not-selected',
  );

  selectAllMatchingElement?.classList.remove('active');
  selectedMsg?.classList.remove('active');
  notSelectedMsg?.classList.add('active');
  if (hiddenField) hiddenField.value = '0';
};

on('change', '#batch_checkbox_all', ({ target }) => {
  if (!(target instanceof HTMLInputElement)) return;

  const selectAllMatchingElement = document.querySelector(
    '.batch-table__select-all',
  );

  target
    .closest('.batch-table')
    ?.querySelectorAll<HTMLInputElement>(batchCheckboxClassName)
    .forEach((content) => {
      content.checked = target.checked;
    });

  if (selectAllMatchingElement) {
    if (target.checked) {
      showSelectAll();
    } else {
      hideSelectAll();
    }
  }
});

on('click', '.batch-table__select-all button', () => {
  const hiddenField = document.querySelector<HTMLInputElement>(
    '#select_all_matching',
  );

  if (!hiddenField) return;

  const active = hiddenField.value === '1';
  const selectedMsg = document.querySelector(
    '.batch-table__select-all .selected',
  );
  const notSelectedMsg = document.querySelector(
    '.batch-table__select-all .not-selected',
  );

  if (!selectedMsg || !notSelectedMsg) return;

  if (active) {
    hiddenField.value = '0';
    selectedMsg.classList.remove('active');
    notSelectedMsg.classList.add('active');
  } else {
    hiddenField.value = '1';
    notSelectedMsg.classList.remove('active');
    selectedMsg.classList.add('active');
  }
});

on('change', batchCheckboxClassName, (event) => {
  const targetTable = (event.target as HTMLElement).closest('.batch-table');
  if (!targetTable) return;

  const checkAllElement = targetTable.querySelector<HTMLInputElement>(
    'input#batch_checkbox_all',
  );
  const selectAllMatchingElement = targetTable.querySelector(
    '.batch-table__select-all',
  );

  if (checkAllElement) {
    const allCheckboxes = Array.from(
      targetTable.querySelectorAll<HTMLInputElement>(batchCheckboxClassName),
    );
    checkAllElement.checked = allCheckboxes.every((content) => content.checked);
    checkAllElement.indeterminate =
      !checkAllElement.checked &&
      allCheckboxes.some((content) => content.checked);

    if (selectAllMatchingElement) {
      if (checkAllElement.checked) {
        showSelectAll();
      } else {
        hideSelectAll();
      }
    }
  }
});

on('change', '.filter-subset--with-select select', ({ target }) => {
  if (target instanceof HTMLSelectElement) target.form?.submit();
});

const onDomainBlockSeverityChange = (target: HTMLSelectElement) => {
  const rejectMediaDiv = document.querySelector(
    '.input.with_label.domain_block_reject_media',
  );
  const rejectReportsDiv = document.querySelector(
    '.input.with_label.domain_block_reject_reports',
  );

  if (rejectMediaDiv && rejectMediaDiv instanceof HTMLElement) {
    rejectMediaDiv.style.display =
      target.value === 'suspend' ? 'none' : 'block';
  }

  if (rejectReportsDiv && rejectReportsDiv instanceof HTMLElement) {
    rejectReportsDiv.style.display =
      target.value === 'suspend' ? 'none' : 'block';
  }
};

on('change', '#domain_block_severity', ({ target }) => {
  if (target instanceof HTMLSelectElement) onDomainBlockSeverityChange(target);
});

const onChangeInviteUsersPermission = (target: HTMLInputElement) => {
  const inviteBypassApprovalCheckbox = document.querySelector<HTMLInputElement>(
    'input#user_role_permissions_as_keys_invite_bypass_approval',
  );

  if (inviteBypassApprovalCheckbox) {
    inviteBypassApprovalCheckbox.disabled = !target.checked;

    if (target.checked) {
      inviteBypassApprovalCheckbox.parentElement?.classList.remove('disabled');
      inviteBypassApprovalCheckbox.parentElement?.parentElement?.classList.remove(
        'disabled',
      );
    } else {
      inviteBypassApprovalCheckbox.parentElement?.classList.add('disabled');
      inviteBypassApprovalCheckbox.parentElement?.parentElement?.classList.add(
        'disabled',
      );
    }
  }
};

on(
  'change',
  'input#user_role_permissions_as_keys_invite_users',
  ({ target }) => {
    if (target instanceof HTMLInputElement) {
      onChangeInviteUsersPermission(target);
    }
  },
);

function onEnableBootstrapTimelineAccountsChange(target: HTMLInputElement) {
  const bootstrapTimelineAccountsField =
    document.querySelector<HTMLInputElement>(
      '#form_admin_settings_bootstrap_timeline_accounts',
    );

  if (bootstrapTimelineAccountsField) {
    bootstrapTimelineAccountsField.disabled = !target.checked;
    if (target.checked) {
      bootstrapTimelineAccountsField.parentElement?.classList.remove(
        'disabled',
      );
      bootstrapTimelineAccountsField.parentElement?.parentElement?.classList.remove(
        'disabled',
      );
    } else {
      bootstrapTimelineAccountsField.parentElement?.classList.add('disabled');
      bootstrapTimelineAccountsField.parentElement?.parentElement?.classList.add(
        'disabled',
      );
    }
  }
}

on(
  'change',
  '#form_admin_settings_enable_bootstrap_timeline_accounts',
  ({ target }) => {
    if (target instanceof HTMLInputElement)
      onEnableBootstrapTimelineAccountsChange(target);
  },
);

const onChangeRegistrationMode = (target: HTMLSelectElement) => {
  const enabled = target.value === 'approved';

  document
    .querySelectorAll<HTMLElement>(
      '.form_admin_settings_registrations_mode .warning-hint',
    )
    .forEach((warning_hint) => {
      warning_hint.style.display = target.value === 'open' ? 'inline' : 'none';
    });

  document
    .querySelectorAll<HTMLInputElement>(
      'input#form_admin_settings_require_invite_text',
    )
    .forEach((input) => {
      input.disabled = !enabled;
      if (enabled) {
        let element: HTMLElement | null = input;
        do {
          element.classList.remove('disabled');
          element = element.parentElement;
        } while (element && !element.classList.contains('fields-group'));
      } else {
        let element: HTMLElement | null = input;
        do {
          element.classList.add('disabled');
          element = element.parentElement;
        } while (element && !element.classList.contains('fields-group'));
      }
    });
};

function convertUTCDateTimeToLocal(value: string) {
  const date = new Date(value + 'Z');
  const twoChars = (x: number) => x.toString().padStart(2, '0');
  return `${date.getFullYear()}-${twoChars(date.getMonth() + 1)}-${twoChars(date.getDate())}T${twoChars(date.getHours())}:${twoChars(date.getMinutes())}`;
}

function convertLocalDatetimeToUTC(value: string) {
  const date = new Date(value);
  const fullISO8601 = date.toISOString();
  return fullISO8601.slice(0, fullISO8601.indexOf('T') + 6);
}

on('change', '#form_admin_settings_registrations_mode', ({ target }) => {
  if (target instanceof HTMLSelectElement) onChangeRegistrationMode(target);
});

async function mountReactComponent(element: Element) {
  const componentName = element.getAttribute('data-admin-component');
  const stringProps = element.getAttribute('data-props');

  if (!stringProps) return;

  const componentProps = JSON.parse(stringProps) as object;

  const { default: AdminComponent } =
    await import('@/mastodon/containers/admin_component');

  const { default: Component } = (await import(
    `@/mastodon/components/admin/${componentName}.jsx`
  )) as { default: React.ComponentType };

  const root = createRoot(element);

  root.render(
    <AdminComponent>
      <Component {...componentProps} />
    </AdminComponent>,
  );
}

ready(() => {
  restoreBrandingSavedColorValues();

  const domainBlockSeveritySelect = document.querySelector<HTMLSelectElement>(
    'select#domain_block_severity',
  );
  if (domainBlockSeveritySelect)
    onDomainBlockSeverityChange(domainBlockSeveritySelect);

  const enableBootstrapTimelineAccounts =
    document.querySelector<HTMLInputElement>(
      'input#form_admin_settings_enable_bootstrap_timeline_accounts',
    );
  if (enableBootstrapTimelineAccounts)
    onEnableBootstrapTimelineAccountsChange(enableBootstrapTimelineAccounts);

  const registrationMode = document.querySelector<HTMLSelectElement>(
    'select#form_admin_settings_registrations_mode',
  );
  if (registrationMode) onChangeRegistrationMode(registrationMode);

  const inviteUsersPermissionChecbkox =
    document.querySelector<HTMLInputElement>(
      'input#user_role_permissions_as_keys_invite_users',
    );
  if (inviteUsersPermissionChecbkox)
    onChangeInviteUsersPermission(inviteUsersPermissionChecbkox);

  const checkAllElement = document.querySelector<HTMLInputElement>(
    '#batch_checkbox_all',
  );
  if (checkAllElement) {
    const allCheckboxes = Array.from(
      document.querySelectorAll<HTMLInputElement>(batchCheckboxClassName),
    );
    checkAllElement.checked = allCheckboxes.every((content) => content.checked);
    checkAllElement.indeterminate =
      !checkAllElement.checked &&
      allCheckboxes.some((content) => content.checked);
  }

  document
    .querySelector<HTMLAnchorElement>('a#add-instance-button')
    ?.addEventListener('click', (e) => {
      const domain = document.querySelector<HTMLInputElement>(
        'input[type="text"]#by_domain',
      )?.value;

      if (domain && e.target instanceof HTMLAnchorElement) {
        const url = new URL(e.target.href);
        url.searchParams.set('_domain', domain);
        e.target.href = url.toString();
      }
    });

  document
    .querySelectorAll<HTMLInputElement>('input[type="datetime-local"]')
    .forEach((element) => {
      if (element.value) {
        element.value = convertUTCDateTimeToLocal(element.value);
      }
      if (element.placeholder) {
        element.placeholder = convertUTCDateTimeToLocal(element.placeholder);
      }
    });

  on('submit', 'form', ({ target }) => {
    if (target instanceof HTMLFormElement)
      target
        .querySelectorAll<HTMLInputElement>('input[type="datetime-local"]')
        .forEach((element) => {
          if (element.value && element.validity.valid) {
            element.value = convertLocalDatetimeToUTC(element.value);
          }
        });
  });

  const announcementStartsAt = document.querySelector<HTMLInputElement>(
    'input[type="datetime-local"]#announcement_starts_at',
  );
  if (announcementStartsAt) {
    setAnnouncementEndsAttributes(announcementStartsAt);
  }

  document.querySelectorAll('[data-admin-component]').forEach((element) => {
    void mountReactComponent(element);
  });

  document
    .querySelectorAll<HTMLCanvasElement>('canvas[data-blurhash]')
    .forEach((canvas) => {
      const blurhash = canvas.dataset.blurhash;
      if (blurhash) {
        try {
          // decode returns a Uint8ClampedArray<ArrayBufferLike> not Uint8ClampedArray<ArrayBuffer>
          const pixels = decode(
            blurhash,
            32,
            32,
          ) as Uint8ClampedArray<ArrayBuffer>;
          const ctx = canvas.getContext('2d');
          const imageData = new ImageData(pixels, 32, 32);

          ctx?.putImageData(imageData, 0, 0);
        } catch (err) {
          if (err instanceof ValidationError) {
            // ignore blurhash validation errors
            return;
          }

          throw err;
        }
      }
    });

  document
    .querySelectorAll<HTMLDivElement>('.preview-card')
    .forEach((previewCard) => {
      const spoilerButton = previewCard.querySelector('.spoiler-button');
      if (!spoilerButton) {
        return;
      }

      spoilerButton.addEventListener('click', () => {
        previewCard.classList.toggle('preview-card--image-visible');
      });
    });
}).catch((reason: unknown) => {
  throw reason;
});
