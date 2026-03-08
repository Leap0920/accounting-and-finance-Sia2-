/**
 * Scroll to Top functionality
 * Handles showing/hiding the button and scrolling back to top.
 */
document.addEventListener('DOMContentLoaded', function () {
    const scrollBtn = document.getElementById('scrollToTop');

    if (!scrollBtn) return;

    // Show button when scrolled certain amount
    window.addEventListener('scroll', function () {
        if (window.pageYOffset > 300) {
            scrollBtn.classList.add('show');
        } else {
            scrollBtn.classList.remove('show');
        }
    });

    // Scroll smoothly to top on click
    scrollBtn.addEventListener('click', function (e) {
        e.preventDefault();
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
});
