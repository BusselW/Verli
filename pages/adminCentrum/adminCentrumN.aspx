<!DOCTYPE html>
<html lang="nl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Centrum - Verlofrooster</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- CSS bestanden -->
    <link rel="icon" href="../../icons/favicon/favicon.svg" />
    <link href="../../css/modern-ui-kit.css" rel="stylesheet">
    <!-- React library -->
    <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="../../js/config/configLijst.js"></script>
    <script src="../../js/config/configLayout.js"></script>

    <style>
        /* Loading spinner styles */
        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f4f6;
            border-top: 4px solid var(--accent, #FF6D22);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>


</head>

<body>
    <div id="root"></div>

    <script type="module">
        console.log('🚀 Admin Centrum starting execution...');
        
        // Make React available to imported ES6 modules
        window.React = React;
        
        // Import required components and functions
        import { getCurrentUser } from '../../js/services/sharepointService.js';
        import { getCurrentUserGroups } from '../../js/services/permissionService.js';

        // Simple permission check function
        const hasAdminAccess = (permissions) => {
            return permissions && permissions.isAdmin;
        };

        // React destructuring
        const { createElement: h, useState, useEffect } = React;

        // =====================
        // Error Boundary
        // =====================
        class ErrorBoundary extends React.Component {
            constructor(props) {
                super(props);
                this.state = { hasError: false, error: null };
            }

            static getDerivedStateFromError(error) {
                return { hasError: true, error };
            }

            componentDidCatch(error, errorInfo) {
                console.error('Error caught by boundary:', error, errorInfo);
            }

            render() {
                if (this.state.hasError) {
                    return h('div', { className: 'error-container' },
                        h('h2', null, 'Er is een onverwachte fout opgetreden'),
                        h('p', null, this.state.error?.message || 'Onbekende fout'),
                        h('button', { onClick: () => window.location.reload() }, 'Vernieuw')
                    );
                }
                return this.props.children;
            }
        }

        // =====================
        // Main Admin Component
        // =====================
        const AdminCentrum = () => {
            const [loading, setLoading] = useState(true);
            const [currentUser, setCurrentUser] = useState(null);
            const [userPermissions, setUserPermissions] = useState({
                isAdmin: false,
                loading: true
            });
            const [activeSection, setActiveSection] = useState('dashboard');

            useEffect(() => {
                checkUserPermissions();
            }, []);

            const checkUserPermissions = async () => {
                try {
                    console.log('🔍 Checking user permissions...');
                    setLoading(true);

                    // Get current user
                    const user = await getCurrentUser();
                    if (!user) {
                        console.warn('⚠️ No user info returned');
                        setLoading(false);
                        return;
                    }
                    setCurrentUser(user);

                    // Get user groups
                    const groupsArray = await getCurrentUserGroups();
                    
                    // Check for admin permissions (SharePoint beheer)
                    const permissions = {
                        isAdmin: groupsArray.some(group => 
                            group.toLowerCase().includes('admin') || 
                            group.toLowerCase().includes('beheerder') ||
                            group.toLowerCase().includes('systeembeheer') ||
                            group.toLowerCase().includes('sharepoint') ||
                            group.toLowerCase().includes('behee') // partial match for 'beheer'
                        ),
                        loading: false
                    };
                    
                    console.log('👥 User groups:', groupsArray);
                    console.log('🔑 Admin permissions:', permissions);

                    setUserPermissions(permissions);

                } catch (error) {
                    console.error('❌ Error checking permissions:', error);
                    setUserPermissions({ isAdmin: false, loading: false });
                } finally {
                    setLoading(false);
                }
            };

            const renderDashboard = () => {
                return h('div', null,
                    h('fieldset', null,
                        h('legend', null, 'Systeemoverzicht'),
                        h('div', { className: 'component-grid component-grid-2-col' },
                            h('div', { className: 'alert alert-info' },
                                h('span', null, `Welkom ${currentUser?.Title || 'Administrator'}`),
                            ),
                            h('div', { className: 'alert alert-success' },
                                h('span', null, 'SharePoint verbinding actief'),
                            )
                        )
                    ),
                    
                    h('fieldset', null,
                        h('legend', null, 'Beschikbare Tools'),
                        h('div', { className: 'component-grid component-grid-2-col' },
                            h('button', { 
                                className: 'btn btn-primary',
                                onClick: () => setActiveSection('permissions')
                            }, 
                                h('i', { className: 'fas fa-users', style: { marginRight: '0.5rem' } }),
                                'Gebruikersrechten'
                            ),
                            h('button', { 
                                className: 'btn btn-secondary',
                                onClick: () => setActiveSection('lists')
                            }, 
                                h('i', { className: 'fas fa-list', style: { marginRight: '0.5rem' } }),
                                'SharePoint Lijsten'
                            ),
                            h('button', { 
                                className: 'btn btn-warning',
                                onClick: () => setActiveSection('settings')
                            }, 
                                h('i', { className: 'fas fa-cog', style: { marginRight: '0.5rem' } }),
                                'Systeeminstellingen'
                            ),
                            h('button', { 
                                className: 'btn btn-info',
                                onClick: () => setActiveSection('logs')
                            }, 
                                h('i', { className: 'fas fa-file-alt', style: { marginRight: '0.5rem' } }),
                                'Systeem Logs'
                            )
                        )
                    ),

                    h('fieldset', null,
                        h('legend', null, 'Snelle Acties'),
                        h('div', { className: 'component-grid' },
                            h('div', { className: 'input-group' },
                                h('input', { 
                                    type: 'text', 
                                    id: 'quickSearch', 
                                    className: 'form-input',
                                    placeholder: ' '
                                }),
                                h('label', { htmlFor: 'quickSearch', className: 'floating-label' }, 'Zoek gebruiker of lijst')
                            ),
                            h('div', { style: { display: 'flex', gap: '1rem', flexWrap: 'wrap' } },
                                h('button', { className: 'btn btn-primary' }, 'Zoeken'),
                                h('button', { className: 'btn btn-secondary' }, 'Reset Cache'),
                                h('button', { className: 'btn btn-danger' }, 'Noodstop')
                            )
                        )
                    )
                );
            };

            const renderPermissions = () => {
                return h('div', null,
                    h('fieldset', null,
                        h('legend', null, 'Gebruikersrechten Beheer'),
                        h('div', { className: 'alert alert-info' },
                            h('span', null, 'Hier kunt u gebruikersrechten en groepen beheren.')
                        ),
                        h('div', { className: 'component-grid' },
                            h('div', { className: 'input-group' },
                                h('select', { 
                                    id: 'userSelect', 
                                    className: 'form-select',
                                    required: true
                                },
                                    h('option', { value: '', disabled: true, selected: true, hidden: true }),
                                    h('option', { value: 'user1' }, 'Gebruiker 1'),
                                    h('option', { value: 'user2' }, 'Gebruiker 2')
                                ),
                                h('label', { htmlFor: 'userSelect', className: 'floating-label' }, 'Selecteer Gebruiker')
                            ),
                            h('div', { className: 'toggle-wrapper' },
                                h('label', { htmlFor: 'adminRights' }, 'Administrator Rechten'),
                                h('label', { className: 'toggle-switch' },
                                    h('input', { type: 'checkbox', id: 'adminRights', className: 'toggle-checkbox' }),
                                    h('span', { className: 'toggle-slider' })
                                )
                            ),
                            h('div', { style: { display: 'flex', gap: '1rem' } },
                                h('button', { className: 'btn btn-primary' }, 'Opslaan'),
                                h('button', { className: 'btn btn-secondary', onClick: () => setActiveSection('dashboard') }, 'Terug')
                            )
                        )
                    )
                );
            };

            const renderContent = () => {
                switch(activeSection) {
                    case 'permissions':
                        return renderPermissions();
                    case 'lists':
                        return h('div', null,
                            h('fieldset', null,
                                h('legend', null, 'SharePoint Lijsten'),
                                h('div', { className: 'alert alert-warning' },
                                    h('span', null, 'SharePoint lijsten beheer wordt binnenkort toegevoegd.')
                                ),
                                h('button', { className: 'btn btn-secondary', onClick: () => setActiveSection('dashboard') }, 'Terug naar Dashboard')
                            )
                        );
                    case 'settings':
                        return h('div', null,
                            h('fieldset', null,
                                h('legend', null, 'Systeeminstellingen'),
                                h('div', { className: 'alert alert-warning' },
                                    h('span', null, 'Systeeminstellingen worden binnenkort toegevoegd.')
                                ),
                                h('button', { className: 'btn btn-secondary', onClick: () => setActiveSection('dashboard') }, 'Terug naar Dashboard')
                            )
                        );
                    case 'logs':
                        return h('div', null,
                            h('fieldset', null,
                                h('legend', null, 'Systeem Logs'),
                                h('div', { className: 'alert alert-info' },
                                    h('span', null, 'Hier worden binnenkort systeem logs weergegeven.')
                                ),
                                h('button', { className: 'btn btn-secondary', onClick: () => setActiveSection('dashboard') }, 'Terug naar Dashboard')
                            )
                        );
                    default:
                        return renderDashboard();
                }
            };

            // Show loading state with modern styling
            if (loading || userPermissions.loading) {
                return h('div', { className: 'container' },
                    h('div', { style: { textAlign: 'center', padding: '3rem' } },
                        h('div', { className: 'loading-spinner', style: { margin: '0 auto 1rem' } }),
                        h('p', null, 'Toegangsrechten controleren...')
                    )
                );
            }

            // Check if user has admin access - show access denied with modern styling
            if (!hasAdminAccess(userPermissions)) {
                return h('div', { className: 'container' },
                    h('div', { style: { textAlign: 'center', padding: '3rem' } },
                        h('div', { 
                            style: { 
                                width: '80px',
                                height: '80px',
                                background: '#fef3c7',
                                borderRadius: '50%',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                margin: '0 auto 2rem'
                            }
                        },
                            h('i', { className: 'fas fa-exclamation-triangle', style: { fontSize: '2rem', color: '#d97706' } })
                        ),
                        h('h2', { style: { marginBottom: '1rem' } }, 'Toegang Geweigerd'),
                        h('p', { style: { color: 'var(--text-secondary)', marginBottom: '2rem' } }, 
                            'U heeft geen voldoende rechten om deze pagina te bekijken. Neem contact op met uw systeembeheerder.'
                        ),
                        h('button', { 
                            className: 'btn btn-primary',
                            onClick: () => window.history.back()
                        }, 'Terug')
                    )
                );
            }

            // Render admin interface with modern design
            return h('div', null,
                // Floating Header
                h('header', { className: 'floating-header' },
                    h('a', { 
                        href: '/sites/mulderT/CustomPW/Verlof/CPW/Rooster/Verlofrooster.aspx', 
                        className: 'header-back-link'
                    },
                        h('svg', { 
                            xmlns: 'http://www.w3.org/2000/svg', 
                            fill: 'none', 
                            viewBox: '0 0 24 24', 
                            strokeWidth: '2.5', 
                            stroke: 'currentColor'
                        },
                            h('path', { 
                                strokeLinecap: 'round', 
                                strokeLinejoin: 'round', 
                                d: 'M15.75 19.5L8.25 12l7.5-7.5' 
                            })
                        ),
                        h('span', null, 'Terug naar Rooster')
                    )
                ),

                // Main Container
                h('div', { className: 'container' },
                    // Page Header
                    h('header', { className: 'page-header' },
                        h('h1', null, 'Admin Centrum'),
                        h('p', null, 'SharePoint beheer en systeeminstellingen')
                    ),

                    // Main Content
                    h('main', null,
                        renderContent()
                    )
                )
            );
        };

        // =====================
        // Application Bootstrap
        // =====================
        const App = () => {
            return h(AdminCentrum);
        };

        // =====================
        // Render Application
        // =====================
        const container = document.getElementById('root');
        const root = ReactDOM.createRoot(container);

        root.render(
            h(ErrorBoundary, null,
                h(App)
            )
        );

        console.log('🎉 Admin Centrum initialized successfully');
    </script>
</body>

</html>