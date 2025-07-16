/**
 * @file configLayout.js
 * @description Global layout and UI configuration for consistent modern design
 * @version 2.0
 * @date 2025
 * 
 * This configuration provides centralized theming, component styles, and layout
 * utilities that can be used across all pages in the Verlofrooster application.
 */

(function() {
    'use strict';

    // Prevent double initialization
    if (typeof window.LayoutConfig !== 'undefined') {
        console.log('LayoutConfig already initialized');
        return;
    }

    /**
     * Global layout and UI configuration object
     */
    window.LayoutConfig = {
        
        /**
         * Design System Configuration
         */
        theme: {
            // CSS Custom Properties for consistent theming
            cssVariables: {
                // Animation easing functions
                '--ease-in-out-quad': 'cubic-bezier(0.45, 0, 0.55, 1)',
                '--ease-out-circ': 'cubic-bezier(0.075, 0.82, 0.165, 1)',

                // Core colors based on new brand identity
                '--bg-primary': '#E6E8EB',      // Light gray background (Donkerblauw 10%)
                '--bg-secondary': '#FFFFFF',     // White
                '--bg-tertiary': '#FFFFFF',      // White (for inputs)
                '--text-primary': '#001935',     // Dark blue
                '--text-secondary': '#99A3AE',   // Gray (Donkerblauw 40%)
                '--border': '#CCD1D7',          // Light gray border (Donkerblauw 20%)
                '--accent': '#FF6D22',          // Orange accent
                '--accent-hover': '#E5621E',     // Darker orange
                '--accent-focus-ring': 'rgba(255, 109, 34, 0.3)',

                // Status colors
                '--danger': '#dc2626',
                '--danger-hover': '#b91c1c',
                '--success': '#16a34a',
                '--warning': '#f59e0b',
                '--info': '#3b82f6',

                // Shadows and effects
                '--shadow': '0 4px 6px -1px rgb(0 0 0 / 0.07), 0 2px 4px -2px rgb(0 0 0 / 0.07)',
                '--shadow-lg': '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -2px rgb(0 0 0 / 0.05)'
            },

            // Typography settings
            typography: {
                fontFamily: "'Inter', system-ui, sans-serif",
                fontSize: {
                    xs: '0.75rem',
                    sm: '0.875rem',
                    base: '1rem',
                    lg: '1.125rem',
                    xl: '1.25rem',
                    '2xl': '1.5rem'
                },
                fontWeight: {
                    normal: '400',
                    medium: '500',
                    semibold: '600',
                    bold: '700'
                }
            }
        },

        /**
         * Component CSS Classes and Utilities
         */
        components: {
            
            // Layout components
            layout: {
                floatingHeader: 'floating-header',
                pageHeader: 'page-header',
                container: 'container',
                mainContent: 'main-content'
            },

            // Form components with floating labels
            forms: {
                container: 'form-container',
                fieldset: 'form-fieldset',
                legend: 'form-legend',
                grid: 'component-grid',
                gridTwoCol: 'component-grid-2-col',
                inputGroup: 'input-group',
                input: 'form-input',
                select: 'form-select',
                textarea: 'form-textarea',
                multiselect: 'form-multiselect',
                floatingLabel: 'floating-label',
                helperText: 'form-helper-text',
                colorPicker: 'form-color-input',
                colorWrapper: 'color-picker-wrapper',
                colorValueGroup: 'color-value-group',
                toggleWrapper: 'toggle-wrapper',
                toggleSwitch: 'toggle-switch',
                toggleCheckbox: 'toggle-checkbox',
                toggleSlider: 'toggle-slider'
            },

            // Button styles
            buttons: {
                base: 'btn',
                primary: 'btn-primary',
                secondary: 'btn-secondary',
                danger: 'btn-danger',
                success: 'btn-success',
                warning: 'btn-warning',
                info: 'btn-info',
                link: 'btn-link',
                sizes: {
                    sm: 'btn-sm',
                    lg: 'btn-lg'
                }
            },

            // Alert/notification components
            alerts: {
                base: 'alert',
                info: 'alert-info',
                success: 'alert-success',
                warning: 'alert-warning',
                danger: 'alert-danger',
                closeBtn: 'alert-close-btn'
            },

            // Badge components
            badges: {
                base: 'badge',
                primary: 'badge-primary',
                secondary: 'badge-secondary',
                success: 'badge-success',
                danger: 'badge-danger',
                warning: 'badge-warning'
            }
        },

        /**
         * Page Layout Templates
         */
        templates: {
            
            /**
             * Creates a standard page structure with floating header
             */
            createStandardPage: function(config = {}) {
                const {
                    title = 'Pagina Titel',
                    subtitle = '',
                    showBackButton = false,
                    backUrl = '',
                    customActions = []
                } = config;

                return `
                <header class="floating-header">
                    ${showBackButton ? `
                    <a href="${backUrl}" class="header-back-link">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
                        </svg>
                        <span>Terug</span>
                    </a>
                    ` : ''}
                    ${customActions.join('')}
                </header>

                <div class="container">
                    <header class="page-header">
                        <h1>${title}</h1>
                        ${subtitle ? `<p>${subtitle}</p>` : ''}
                    </header>
                    <main id="page-content">
                        <!-- Page content will be inserted here -->
                    </main>
                </div>`;
            },

            /**
             * Creates a form fieldset with legend
             */
            createFieldset: function(legend, content, gridClass = '') {
                return `
                <fieldset>
                    <legend>${legend}</legend>
                    <div class="component-grid ${gridClass}">
                        ${content}
                    </div>
                </fieldset>`;
            },

            /**
             * Creates a floating label input group
             */
            createFloatingInput: function(config = {}) {
                const {
                    id,
                    type = 'text',
                    label,
                    placeholder = ' ',
                    required = false,
                    value = '',
                    readonly = false,
                    disabled = false,
                    helperText = '',
                    className = ''
                } = config;

                return `
                <div class="input-group ${className}">
                    <input 
                        type="${type}" 
                        id="${id}" 
                        name="${id}" 
                        class="form-input" 
                        placeholder="${placeholder}"
                        ${required ? 'required' : ''}
                        ${readonly ? 'readonly' : ''}
                        ${disabled ? 'disabled' : ''}
                        value="${value}">
                    <label for="${id}" class="floating-label">${label}</label>
                    ${helperText ? `<p class="form-helper-text">${helperText}</p>` : ''}
                </div>`;
            },

            /**
             * Creates a floating label select group
             */
            createFloatingSelect: function(config = {}) {
                const {
                    id,
                    label,
                    options = [],
                    required = false,
                    value = '',
                    disabled = false,
                    helperText = '',
                    className = '',
                    multiple = false
                } = config;

                const optionsHtml = options.map(option => 
                    `<option value="${option.value}" ${option.value === value ? 'selected' : ''}>${option.text}</option>`
                ).join('');

                return `
                <div class="input-group ${className}">
                    <select 
                        id="${id}" 
                        name="${id}" 
                        class="form-select ${multiple ? 'form-multiselect' : ''}" 
                        ${required ? 'required' : ''}
                        ${disabled ? 'disabled' : ''}
                        ${multiple ? 'multiple' : ''}>
                        ${!multiple ? '<option value="" disabled selected hidden></option>' : ''}
                        ${optionsHtml}
                    </select>
                    <label for="${id}" class="floating-label">${label}</label>
                    ${helperText ? `<p class="form-helper-text">${helperText}</p>` : ''}
                </div>`;
            },

            /**
             * Creates a toggle switch
             */
            createToggleSwitch: function(config = {}) {
                const {
                    id,
                    label,
                    checked = false,
                    disabled = false
                } = config;

                return `
                <div class="toggle-wrapper">
                    <label for="${id}">${label}</label>
                    <label class="toggle-switch">
                        <input type="checkbox" id="${id}" class="toggle-checkbox" ${checked ? 'checked' : ''} ${disabled ? 'disabled' : ''}>
                        <span class="toggle-slider"></span>
                    </label>
                </div>`;
            },

            /**
             * Creates an alert/notification
             */
            createAlert: function(config = {}) {
                const {
                    type = 'info',
                    message,
                    dismissible = true
                } = config;

                return `
                <div class="alert alert-${type}">
                    <span>${message}</span>
                    ${dismissible ? `
                    <button class="alert-close-btn" onclick="this.parentElement.style.display='none'">&times;</button>
                    ` : ''}
                </div>`;
            },

            /**
             * Creates a badge
             */
            createBadge: function(text, type = 'primary') {
                return `<span class="badge badge-${type}">${text}</span>`;
            }
        },

        /**
         * CSS Injection Utilities
         */
        styles: {
            
            /**
             * Injects the core CSS variables into the document
             */
            injectCSSVariables: function() {
                const cssVars = this.theme.cssVariables;
                const rootStyle = Object.entries(cssVars)
                    .map(([key, value]) => `${key}: ${value}`)
                    .join('; ');
                
                // Create or update existing style element
                let styleElement = document.getElementById('layout-config-vars');
                if (!styleElement) {
                    styleElement = document.createElement('style');
                    styleElement.id = 'layout-config-vars';
                    document.head.appendChild(styleElement);
                }
                
                styleElement.textContent = `:root { ${rootStyle} }`;
            },

            /**
             * Injects core component styles
             */
            injectCoreStyles: function() {
                const coreCSS = `
                /* LayoutConfig Core Styles */
                *, *::before, *::after { box-sizing: border-box; }
                
                body {
                    font-family: var(--font-family, ${this.theme.typography.fontFamily});
                    background-color: var(--bg-primary);
                    color: var(--text-primary);
                    margin: 0;
                    padding: 0;
                }

                /* Floating Header */
                .floating-header {
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    background-color: var(--text-primary);
                    color: var(--bg-secondary);
                    padding: 0.75rem 1.5rem;
                    display: flex;
                    align-items: center;
                    justify-content: flex-start;
                    z-index: 1000;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                }

                .header-back-link {
                    color: var(--bg-secondary);
                    background-color: transparent;
                    text-decoration: none;
                    font-weight: 600;
                    font-size: 0.875rem;
                    display: inline-flex;
                    align-items: center;
                    gap: 0.5rem;
                    padding: 0.5rem 0.75rem;
                    border-radius: 0.375rem;
                    transition: background-color 0.2s var(--ease-in-out-quad);
                }

                .header-back-link:hover {
                    background-color: rgba(255, 255, 255, 0.1);
                }

                .header-back-link svg {
                    width: 1rem;
                    height: 1rem;
                }

                /* Main Container */
                .container {
                    max-width: 42rem;
                    margin: auto;
                    background-color: var(--bg-secondary);
                    padding: 1.5rem;
                    border-radius: 1rem;
                    box-shadow: var(--shadow);
                    border: 1px solid var(--border);
                    margin-top: 5rem; /* Account for floating header */
                }

                /* Page Header */
                .page-header {
                    margin-bottom: 1.5rem;
                    border-bottom: 1px solid var(--border);
                    padding-bottom: 1rem;
                }
                
                .page-header h1 { 
                    font-size: 1.5rem; 
                    font-weight: 700; 
                    margin: 0; 
                }
                
                .page-header p { 
                    margin: 0.25rem 0 0; 
                    color: var(--text-secondary); 
                    font-size: 0.875rem; 
                }
                `;

                let styleElement = document.getElementById('layout-config-core');
                if (!styleElement) {
                    styleElement = document.createElement('style');
                    styleElement.id = 'layout-config-core';
                    document.head.appendChild(styleElement);
                }
                
                styleElement.textContent = coreCSS;
            }
        },

        /**
         * Initialization function
         */
        init: function() {
            console.log('🎨 Initializing LayoutConfig...');
            
            // Inject CSS variables and core styles
            this.styles.injectCSSVariables.call(this);
            this.styles.injectCoreStyles.call(this);
            
            // Add Google Fonts if not already present
            if (!document.querySelector('link[href*="fonts.googleapis.com"]')) {
                const fontLink = document.createElement('link');
                fontLink.rel = 'stylesheet';
                fontLink.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap';
                document.head.appendChild(fontLink);
            }
            
            console.log('✅ LayoutConfig initialized successfully');
        }
    };

    // Auto-initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => window.LayoutConfig.init());
    } else {
        window.LayoutConfig.init();
    }

    console.log('📦 LayoutConfig module loaded');

})();
