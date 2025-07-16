<!DOCTYPE html>
<html lang="nl">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Centrum - Verlofrooster</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- CSS bestanden -->
    <link rel="icon" href="../../icons/favicon/favicon.svg" />
	<link href="../config/confCSS.css" rel="stylesheet">
    <!-- React library -->
    <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="../../js/config/configLijst.js"></script>


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
        import { GHeader, hasAdminAccess, AccessDenied, navigateBack } from '../config/confPages.js';

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

            // Show loading state
            if (loading || userPermissions.loading) {
                return h('div', { className: 'loading-container' },
                    h('div', { className: 'loading-spinner' }),
                    h('p', null, 'Toegangsrechten controleren...')
                );
            }

            // Check if user has admin access
            if (!hasAdminAccess(userPermissions)) {
                return h(AccessDenied);
            }

            // Render admin interface
            return h('div', null,
                h(GHeader, {
                    title: 'Admin Centrum',
                    subtitle: 'SharePoint beheer en systeeminstellingen',
                    onBack: navigateBack
                }),
                h('div', { className: 'main-content' },
                    h('div', { className: 'admin-welcome' },
                        h('h2', null, `Welkom ${currentUser?.Title || 'Administrator'}`),
                        h('p', null, 'Hier kunt u SharePoint beheer functionaliteiten uitvoeren en systeeminstellingen aanpassen.'),
                        h('div', { style: { marginTop: '2rem' } },
                            h('p', { style: { color: '#6b7280', fontSize: '0.9rem' } }, 
                                'Deze pagina is alleen toegankelijk voor gebruikers met SharePoint beheer rechten.'
                            )
                        )
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