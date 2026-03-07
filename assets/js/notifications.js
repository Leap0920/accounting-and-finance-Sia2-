/**
 * Notifications Loader
 * Dynamically loads notifications from activity_logs via API
 */

(function () {
    'use strict';

    // Configuration - determine API path based on current location
    const currentPath = window.location.pathname;
    const isCorePage = currentPath.includes('/core/');
    const NOTIFICATIONS_API = isCorePage ? '../modules/api/notifications.php' : '../modules/api/notifications.php';
    const REFRESH_INTERVAL = 30000; // 30 seconds
    const MAX_NOTIFICATIONS = 10;

    let refreshTimer = null;

    /**
     * Initialize notifications on page load
     */
    function initNotifications() {
        console.log('Initializing notifications...');
        console.log('API Path:', NOTIFICATIONS_API);
        loadNotifications();

        // Set up auto-refresh
        if (refreshTimer) {
            clearInterval(refreshTimer);
        }
        refreshTimer = setInterval(loadNotifications, REFRESH_INTERVAL);
    }

    /**
     * Load notifications from API
     */
    function loadNotifications() {
        const url = NOTIFICATIONS_API + '?limit=' + MAX_NOTIFICATIONS;
        console.log('Loading notifications from:', url);

        fetch(url, {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Accept': 'application/json'
            }
        })
            .then(response => {
                console.log('Response status:', response.status);
                if (!response.ok) {
                    throw new Error('HTTP error! status: ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                console.log('Notifications data received:', data);
                if (data.success) {
                    updateNotificationBadge(data.count);
                    updateNotificationDropdown(data.notifications);
                } else {
                    console.error('Failed to load notifications:', data.message);
                    handleNotificationError();
                }
            })
            .catch(error => {
                console.error('Error loading notifications:', error);
                console.error('Error details:', error.message);
                handleNotificationError();
            });
    }

    /**
     * Update notification badge count
     */
    function updateNotificationBadge(count) {
        const badge = document.querySelector('.notification-badge');
        if (badge) {
            if (count > 0) {
                badge.textContent = count > 99 ? '99+' : count;
                badge.style.display = 'inline-block';
            } else {
                badge.textContent = '0';
                badge.style.display = 'none';
            }
        }
    }

    /**
     * Update notification dropdown content
     */
    function updateNotificationDropdown(notifications) {
        const dropdown = document.querySelector('.notifications-dropdown');
        if (!dropdown) {
            console.warn('Notifications dropdown not found in DOM');
            return;
        }

        console.log('Updating dropdown with', notifications.length, 'notifications');

        // Target the dedicated scrollable list container
        const listContainer = document.getElementById('notification-list');
        if (!listContainer) {
            console.warn('Notification list container (#notification-list) not found');
            return;
        }

        // Clear the scrollable area
        listContainer.innerHTML = '';

        // Determine correct path for activity-log
        const currentPath = window.location.pathname;
        const isCorePage = currentPath.includes('/core/');
        const activityLogPath = isCorePage ? '../modules/activity-log.php' : 'activity-log.php';

        // Update existing "View All" link href
        const viewAllLink = dropdown.querySelector('a[href*="activity-log"]');
        if (viewAllLink) {
            viewAllLink.href = activityLogPath;
        }

        if (notifications.length === 0) {
            const noNotifications = document.createElement('li');
            noNotifications.className = 'dropdown-item text-center text-muted py-3';
            noNotifications.innerHTML = '<small>No new notifications</small>';
            listContainer.appendChild(noNotifications);
        } else {
            notifications.forEach((notification, index) => {
                const listItem = document.createElement('li');

                const link = document.createElement('a');
                link.href = '#';
                link.className = 'dropdown-item notification-item';
                link.style.textDecoration = 'none';
                link.onclick = function (e) {
                    e.preventDefault();
                    window.location.href = activityLogPath;
                };

                link.innerHTML = `
                    <i class="fas ${notification.icon} ${notification.color}"></i>
                    <div class="notification-content">
                        <strong>${escapeHtml(notification.title)}</strong>
                        <small>${escapeHtml(notification.details)}</small>
                        <br><small class="text-muted" style="font-size: 0.75rem;">${notification.time_ago}</small>
                    </div>
                `;

                listItem.appendChild(link);
                listContainer.appendChild(listItem);

                // Add divider between notifications (except after last)
                if (index < notifications.length - 1) {
                    const itemDivider = document.createElement('li');
                    itemDivider.innerHTML = '<hr class="dropdown-divider my-0">';
                    listContainer.appendChild(itemDivider);
                }
            });
        }
    }

    /**
     * Handle notification loading error
     */
    function handleNotificationError() {
        // Show error state but don't break the UI
        const badge = document.querySelector('.notification-badge');
        if (badge) {
            badge.style.display = 'none';
        }

        // Update the scroll container to show error message
        const listContainer = document.getElementById('notification-list');
        if (listContainer) {
            listContainer.innerHTML = '<li class="dropdown-item text-center text-muted py-3"><small>Unable to load notifications</small></li>';
        }
    }

    /**
     * Escape HTML to prevent XSS
     */
    function escapeHtml(text) {
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text ? String(text).replace(/[&<>"']/g, m => map[m]) : '';
    }

    /**
     * Clean up on page unload
     */
    function cleanup() {
        if (refreshTimer) {
            clearInterval(refreshTimer);
            refreshTimer = null;
        }
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initNotifications);
    } else {
        initNotifications();
    }

    // Cleanup on page unload
    window.addEventListener('beforeunload', cleanup);

})();

