(function ($) {
    'use strict';

    if (!$) {
        return;
    }

    const currentUserRole = window.currentUserRole || '';
    const currentModule = window.currentModule || '';
    const trackerUrl = window.superAuditTrackerUrl || '';
    const trackedElementsSelector = 'a, button, [role="button"], .btn, .nav-link, .dropdown-item, .page-link, [data-bs-toggle], [onclick], th[data-sort], [data-action]';

    if (!trackerUrl || !currentModule || currentUserRole === 'Administrator') {
        return;
    }

    const truncate = (value, maxLength) => {
        if (!value) {
            return '';
        }

        const normalized = String(value).replace(/\s+/g, ' ').trim();
        return normalized.slice(0, maxLength);
    };

    const classifyActionType = (element) => {
        if (!element) {
            return 'button_click';
        }

        if (element.closest('.nav-tabs, .chart-tabs') || element.getAttribute('role') === 'tab') {
            return 'tab_switch';
        }

        if (element.classList.contains('dropdown-item') || element.closest('.dropdown-menu')) {
            return 'dropdown_select';
        }

        if (element.tagName === 'A') {
            return 'link_click';
        }

        return 'button_click';
    };

    const sendEvent = (payload) => {
        $.ajax({
            url: trackerUrl,
            type: 'POST',
            data: JSON.stringify(payload),
            contentType: 'application/json',
            timeout: 3000
        });
    };

    $(document).on('click', trackedElementsSelector, function () {
        const element = this.closest(trackedElementsSelector) || this;
        const payload = {
            action_type: classifyActionType(element),
            module: currentModule,
            element_tag: truncate(element.tagName || '', 50),
            element_id: truncate(element.id || '', 200),
            element_class: truncate(element.className || '', 500),
            element_text: truncate(element.innerText || element.textContent || element.getAttribute('aria-label') || element.title || '', 500),
            element_href: truncate(element.getAttribute('href') || element.dataset.href || '', 500),
            page_url: truncate(window.location.pathname + window.location.search + window.location.hash, 500)
        };

        sendEvent(payload);
    });

    $(document).on('show.bs.modal', '.modal', function () {
        const titleElement = this.querySelector('.modal-title, [data-modal-title], h1, h2, h3, h4, h5');
        sendEvent({
            action_type: 'modal_open',
            module: currentModule,
            element_tag: 'DIV',
            element_id: truncate(this.id || '', 200),
            element_class: truncate(this.className || '', 500),
            element_text: truncate(titleElement ? titleElement.textContent : 'Modal opened', 500),
            element_href: '',
            page_url: truncate(window.location.pathname + window.location.search + window.location.hash, 500)
        });
    });

    $(document).on('submit', 'form', function () {
        sendEvent({
            action_type: 'form_submit',
            module: currentModule,
            element_tag: 'FORM',
            element_id: truncate(this.id || '', 200),
            element_class: truncate(this.className || '', 500),
            element_text: truncate(this.getAttribute('action') || this.getAttribute('name') || 'Form submitted', 500),
            element_href: truncate(this.getAttribute('action') || '', 500),
            page_url: truncate(window.location.pathname + window.location.search + window.location.hash, 500)
        });
    });
})(window.jQuery);