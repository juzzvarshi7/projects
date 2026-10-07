document.addEventListener('DOMContentLoaded', function() {
    // Slider functionality
    let currentSlide = 0;
    const slides = document.querySelectorAll('.slide');
    const sliderNextBtn = document.querySelector('.slider-next-btn');
    const sliderPrevBtn = document.querySelector('.slider-prev-btn');

    function showSlide(index) {
        slides.forEach((slide, i) => {
            slide.style.display = i === index ? 'block' : 'none';
        });
    }

    sliderNextBtn.addEventListener('click', () => {
        currentSlide = (currentSlide + 1) % slides.length;
        showSlide(currentSlide);
    });

    sliderPrevBtn.addEventListener('click', () => {
        currentSlide = (currentSlide - 1 + slides.length) % slides.length;
        showSlide(currentSlide);
    });

    showSlide(currentSlide);

    // Services functionality
    const servicesContent = document.querySelector('.services-content');
    const servicesNextBtn = document.querySelector('.services-next-btn');
    const servicesPrevBtn = document.querySelector('.services-prev-btn');

    servicesNextBtn.addEventListener('click', () => {
        servicesContent.scrollLeft += servicesContent.clientWidth;
    });

    servicesPrevBtn.addEventListener('click', () => {
        servicesContent.scrollLeft -= servicesContent.clientWidth;
    });

    // Side menu functionality
    const sideMenu = document.getElementById('side-menu');
    const menuBtn = document.getElementById('menu-btn');
    const closeBtn = document.getElementById('close-btn');

    menuBtn.addEventListener('click', () => {
        sideMenu.style.left = '0';
    });

    closeBtn.addEventListener('click', () => {
        sideMenu.style.left = '-300px';
    });
});