// JavaScript for services section navigation buttons

const prevBtn = document.querySelector('.services-prev-btn');
const nextBtn = document.querySelector('.services-next-btn');
const servicesContainer = document.querySelector('.services-container');

let scrollStep = servicesContainer.clientWidth;

prevBtn.addEventListener('click', () => {
    servicesContainer.scrollBy({
        top: 0,
        left: -scrollStep,
        behavior: 'smooth'
    });
});

nextBtn.addEventListener('click', () => {
    servicesContainer.scrollBy({
        top: 0,
        left: scrollStep,
        behavior: 'smooth'
    });
});
