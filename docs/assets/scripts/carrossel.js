document.addEventListener("DOMContentLoaded", () => {
    const track = document.getElementById("track");
    const prevBtn = document.getElementById("prevBtn");
    const nextBtn = document.getElementById("nextBtn");
    const dotsContainer = document.getElementById("carouselDots");

    if (!track || !prevBtn || !nextBtn) return;

    const slides = Array.from(track.children);
    let currentIndex = 0;

    // Cria os indicadores (dots)
    if (dotsContainer) {
        slides.forEach((_, idx) => {
            const dot = document.createElement("button");
            dot.type = "button";
            dot.className = `carousel-dot${idx === 0 ? " active" : ""}`;
            dot.setAttribute("aria-label", `Ir para o slide ${idx + 1}`);
            dot.addEventListener("click", () => scrollToSlide(idx));
            dotsContainer.appendChild(dot);
        });
    }

    const updateActiveUI = (index) => {
        currentIndex = index;
        slides.forEach((slide, idx) => {
            slide.classList.toggle("active", idx === currentIndex);
        });
        if (dotsContainer) {
            const dots = Array.from(dotsContainer.children);
            dots.forEach((dot, idx) => {
                dot.classList.toggle("active", idx === currentIndex);
            });
        }
    };

    const scrollToSlide = (index) => {
        const boundedIndex = (index + slides.length) % slides.length;
        const targetSlide = slides[boundedIndex];
        if (!targetSlide) return;

        const trackRect = track.getBoundingClientRect();
        const slideRect = targetSlide.getBoundingClientRect();
        const offset = (slideRect.left - trackRect.left) + track.scrollLeft - (trackRect.width / 2) + (slideRect.width / 2);

        track.scrollTo({
            left: Math.max(0, offset),
            behavior: "smooth"
        });

        updateActiveUI(boundedIndex);
    };

    // Detecta o slide mais próximo do centro durante scroll manual/swipe
    const detectCenteredSlide = () => {
        const trackCenter = track.getBoundingClientRect().left + (track.offsetWidth / 2);
        let closestIndex = 0;
        let minDistance = Infinity;

        slides.forEach((slide, idx) => {
            const rect = slide.getBoundingClientRect();
            const slideCenter = rect.left + (rect.width / 2);
            const distance = Math.abs(trackCenter - slideCenter);
            if (distance < minDistance) {
                minDistance = distance;
                closestIndex = idx;
            }
        });

        updateActiveUI(closestIndex);
    };

    let scrollTimeout;
    track.addEventListener("scroll", () => {
        window.clearTimeout(scrollTimeout);
        scrollTimeout = window.setTimeout(detectCenteredSlide, 60);
    });

    prevBtn.addEventListener("click", () => {
        scrollToSlide(currentIndex - 1);
    });

    nextBtn.addEventListener("click", () => {
        scrollToSlide(currentIndex + 1);
    });

    // Permite clicar em um slide lateral para centralizá-lo
    slides.forEach((slide, idx) => {
        slide.addEventListener("click", () => {
            if (idx !== currentIndex) {
                scrollToSlide(idx);
            }
        });
    });

    updateActiveUI(0);
});