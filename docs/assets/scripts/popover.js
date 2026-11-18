document.addEventListener("DOMContentLoaded", () => {
    // 1. Menu Mobile
    const mobileMenuBtn = document.getElementById("mobileMenuBtn");
    const mobileDrawer = document.getElementById("mobileDrawer");

    if (mobileMenuBtn && mobileDrawer) {
        mobileMenuBtn.addEventListener("click", () => {
            const isOpen = mobileDrawer.classList.toggle("open");
            mobileMenuBtn.setAttribute("aria-expanded", String(isOpen));
            mobileMenuBtn.textContent = isOpen ? "✕" : "☰";
        });

        mobileDrawer.querySelectorAll("a").forEach(link => {
            link.addEventListener("click", () => {
                mobileDrawer.classList.remove("open");
                mobileMenuBtn.setAttribute("aria-expanded", "false");
                mobileMenuBtn.textContent = "☰";
            });
        });
    }

    // 2. Abas do Console Interativo na Hero Section
    const showcaseTabs = document.querySelectorAll(".showcase-tab");
    const showcasePanes = document.querySelectorAll(".showcase-pane");
    const showControlsBtn = document.getElementById("showControlsBtn");

    const activateShowcaseTab = (targetPaneId) => {
        showcaseTabs.forEach(tab => {
            const isMatch = tab.getAttribute("data-pane") === targetPaneId;
            tab.classList.toggle("active", isMatch);
            tab.setAttribute("aria-selected", String(isMatch));
        });

        showcasePanes.forEach(pane => {
            pane.classList.toggle("active", pane.id === targetPaneId);
        });
    };

    showcaseTabs.forEach(tab => {
        tab.addEventListener("click", () => {
            const targetPane = tab.getAttribute("data-pane");
            if (targetPane) activateShowcaseTab(targetPane);
        });
    });

    if (showControlsBtn) {
        showControlsBtn.addEventListener("click", () => {
            activateShowcaseTab("pane-controls");
            const showcase = document.querySelector(".hero-showcase");
            if (showcase) {
                showcase.scrollIntoView({ behavior: "smooth", block: "center" });
            }
        });
    }

    // 3. Filtro de Integrantes da Equipe por Frente de Trabalho
    const filterButtons = document.querySelectorAll(".filter-btn");
    const teamCards = document.querySelectorAll(".team-card");

    filterButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const filterValue = btn.getAttribute("data-filter") || "all";

            filterButtons.forEach(b => b.classList.remove("active"));
            btn.classList.add("active");

            teamCards.forEach(card => {
                const category = card.getAttribute("data-category");
                const shouldShow = filterValue === "all" || category === filterValue;
                card.classList.toggle("hidden-card", !shouldShow);
            });
        });
    });

    // 4. Popover Global de Inspeção de Evidências de Código
    const popover = document.getElementById("popoverGlobal");
    const codeChips = document.querySelectorAll(".code-chip[data-code-title]");

    if (popover && codeChips.length > 0) {
        const showPopover = (chip, event) => {
            const title = chip.getAttribute("data-code-title") || "";
            const desc = chip.getAttribute("data-code-desc") || "";
            popover.innerHTML = `<strong>${title}</strong><span>${desc}</span>`;
            popover.classList.add("mostrar");
            popover.setAttribute("aria-hidden", "false");
            positionPopover(event);
        };

        const positionPopover = (event) => {
            const padding = 14;
            const rect = popover.getBoundingClientRect();
            let left = event.clientX + 12;
            let top = event.clientY + 16;

            if (left + rect.width > window.innerWidth - padding) {
                left = window.innerWidth - rect.width - padding;
            }
            if (top + rect.height > window.innerHeight - padding) {
                top = event.clientY - rect.height - 12;
            }

            popover.style.left = `${Math.max(padding, left)}px`;
            popover.style.top = `${Math.max(padding, top)}px`;
        };

        const hidePopover = () => {
            popover.classList.remove("mostrar");
            popover.setAttribute("aria-hidden", "true");
        };

        codeChips.forEach(chip => {
            chip.addEventListener("mouseenter", (e) => showPopover(chip, e));
            chip.addEventListener("mousemove", positionPopover);
            chip.addEventListener("mouseleave", hidePopover);
            chip.addEventListener("blur", hidePopover);
        });
    }

    // 5. Destaque Automático da Seção Ativa na Navbar durante o Scroll
    const sections = document.querySelectorAll("main section[id]");
    const navAnchors = document.querySelectorAll(".nav-links a");

    const updateActiveNav = () => {
        const scrollPos = window.scrollY + 140;
        sections.forEach(section => {
            const top = section.offsetTop;
            const height = section.offsetHeight;
            const id = section.getAttribute("id");

            if (scrollPos >= top && scrollPos < top + height) {
                navAnchors.forEach(a => {
                    a.classList.toggle("active", a.getAttribute("href") === `#${id}`);
                });
            }
        });
    };

    window.addEventListener("scroll", updateActiveNav, { passive: true });
    updateActiveNav();
});
