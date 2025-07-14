/**
 * @file Mededelingen.js
 * @description Component for displaying and managing announcements/mededelingen
 * Shows active announcements based on date range and target audience
 * Provides interface for privileged users to create new announcements
 */

import { fetchSharePointList, createSharePointListItem } from '../services/sharepointService.js';
import { getCurrentUserInfo } from '../services/sharepointService.js';
import { canManageOthersEvents } from './ContextMenu.js';

const { createElement: h, useState, useEffect, useRef } = React;

/**
 * Mededelingen Component
 * @param {Object} props - Component props
 * @param {Array} props.teams - Available teams for targeting announcements
 */
const Mededelingen = ({ teams = [] }) => {
    const [announcements, setAnnouncements] = useState([]);
    const [showCreateForm, setShowCreateForm] = useState(false);
    const [canManageAnnouncements, setCanManageAnnouncements] = useState(false);
    const [loading, setLoading] = useState(true);
    const [currentUser, setCurrentUser] = useState(null);

    // Form state
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        startDate: '',
        endDate: '',
        targetTeams: []
    });

    useEffect(() => {
        initializeComponent();
    }, []);

    const initializeComponent = async () => {
        try {
            setLoading(true);

            // Check user permissions
            const user = await getCurrentUserInfo();
            setCurrentUser(user);
            
            const hasPermissions = await canManageOthersEvents();
            setCanManageAnnouncements(hasPermissions);

            // Load announcements
            await loadAnnouncements();
        } catch (error) {
            console.error('Error initializing Mededelingen component:', error);
        } finally {
            setLoading(false);
        }
    };

    const loadAnnouncements = async () => {
        try {
            const allAnnouncements = await fetchSharePointList('Mededeling');
            const activeAnnouncements = filterActiveAnnouncements(allAnnouncements);
            setAnnouncements(activeAnnouncements);
        } catch (error) {
            console.error('Error loading announcements:', error);
        }
    };

    const filterActiveAnnouncements = (announcements) => {
        const now = new Date();
        
        return announcements.filter(announcement => {
            // Check if announcement is within date range
            const startDate = announcement.DatumTijdStart ? new Date(announcement.DatumTijdStart) : null;
            const endDate = announcement.DatumTijdEinde ? new Date(announcement.DatumTijdEinde) : null;

            const isActive = (!startDate || startDate <= now) && (!endDate || endDate >= now);

            // Check team targeting
            if (announcement.UitzendenAan && announcement.UitzendenAan.trim()) {
                const targetTeams = announcement.UitzendenAan.split(';').map(team => team.trim());
                
                // If "Alle teams" is in the target list, show to everyone
                if (targetTeams.includes('Alle teams')) {
                    return isActive;
                }
                
                // TODO: When user team info becomes available, check if user's team is in targetTeams
                // For now, show all active announcements that have team targeting
                return isActive;
            }
            
            // If no targeting specified, show to everyone
            return isActive;
        });
    };

    const handleCreateAnnouncement = async (e) => {
        e.preventDefault();
        
        if (!currentUser) {
            alert('Gebruikersinformatie niet beschikbaar');
            return;
        }

        try {
            const username = currentUser.LoginName?.split('|')[1] || currentUser.LoginName;
            
            const announcementData = {
                Title: formData.title,
                Aanvulling: formData.description,
                DatumTijdStart: formData.startDate ? new Date(formData.startDate).toISOString() : null,
                DatumTijdEinde: formData.endDate ? new Date(formData.endDate).toISOString() : null,
                UitzendenAan: formData.targetTeams.join('; '),
                username: username
            };

            await createSharePointListItem('Mededeling', announcementData);
            
            // Reset form and reload announcements
            setFormData({
                title: '',
                description: '',
                startDate: '',
                endDate: '',
                targetTeams: []
            });
            setShowCreateForm(false);
            
            await loadAnnouncements();
            
            console.log('✅ Announcement created successfully');
        } catch (error) {
            console.error('❌ Error creating announcement:', error);
            alert('Fout bij het aanmaken van de mededeling: ' + error.message);
        }
    };

    const handleTeamToggle = (teamName) => {
        setFormData(prev => ({
            ...prev,
            targetTeams: prev.targetTeams.includes(teamName)
                ? prev.targetTeams.filter(t => t !== teamName)
                : [...prev.targetTeams, teamName]
        }));
    };

    const formatDate = (dateString) => {
        if (!dateString) return '';
        return new Date(dateString).toLocaleDateString('nl-NL', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
    };

    if (loading) {
        return h('div', { className: 'mededelingen-container loading' },
            h('div', { className: 'loading-spinner' }),
            h('span', null, 'Mededelingen laden...')
        );
    }

    // Don't render if no announcements and user can't manage them
    if (announcements.length === 0 && !canManageAnnouncements) {
        return null;
    }

    return h('div', { className: 'mededelingen-container' },
        // Header with title and create button
        h('div', { className: 'mededelingen-header' },
            h('h3', { className: 'mededelingen-title' },
                h('i', { className: 'fas fa-bullhorn' }),
                ' Mededelingen'
            ),
            canManageAnnouncements && h('button', {
                className: 'btn-create-announcement',
                onClick: () => setShowCreateForm(!showCreateForm),
                title: 'Nieuwe mededeling aanmaken'
            },
                h('i', { className: 'fas fa-plus' }),
                ' Nieuwe mededeling'
            )
        ),

        // Create form (if visible)
        showCreateForm && h('div', { className: 'announcement-form-container' },
            h('form', { className: 'announcement-form', onSubmit: handleCreateAnnouncement },
                h('div', { className: 'form-group' },
                    h('label', { htmlFor: 'announcement-title' }, 'Titel:'),
                    h('input', {
                        id: 'announcement-title',
                        type: 'text',
                        value: formData.title,
                        onChange: (e) => setFormData(prev => ({ ...prev, title: e.target.value })),
                        required: true,
                        placeholder: 'Titel van de mededeling'
                    })
                ),
                h('div', { className: 'form-group' },
                    h('label', { htmlFor: 'announcement-description' }, 'Beschrijving:'),
                    h('textarea', {
                        id: 'announcement-description',
                        value: formData.description,
                        onChange: (e) => setFormData(prev => ({ ...prev, description: e.target.value })),
                        required: true,
                        placeholder: 'Inhoud van de mededeling',
                        rows: 3
                    })
                ),
                h('div', { className: 'form-row' },
                    h('div', { className: 'form-group' },
                        h('label', { htmlFor: 'announcement-start' }, 'Startdatum:'),
                        h('input', {
                            id: 'announcement-start',
                            type: 'datetime-local',
                            value: formData.startDate,
                            onChange: (e) => setFormData(prev => ({ ...prev, startDate: e.target.value }))
                        })
                    ),
                    h('div', { className: 'form-group' },
                        h('label', { htmlFor: 'announcement-end' }, 'Einddatum:'),
                        h('input', {
                            id: 'announcement-end',
                            type: 'datetime-local',
                            value: formData.endDate,
                            onChange: (e) => setFormData(prev => ({ ...prev, endDate: e.target.value }))
                        })
                    )
                ),
                h('div', { className: 'form-group' },
                    h('label', null, 'Doelgroep teams:'),
                    h('div', { className: 'team-checkboxes' },
                        teams.map(team => 
                            h('label', { 
                                key: team.Id || team.Naam,
                                className: 'team-checkbox'
                            },
                                h('input', {
                                    type: 'checkbox',
                                    checked: formData.targetTeams.includes(team.Naam),
                                    onChange: () => handleTeamToggle(team.Naam)
                                }),
                                h('span', null, team.Naam)
                            )
                        ),
                        h('label', { className: 'team-checkbox' },
                            h('input', {
                                type: 'checkbox',
                                checked: formData.targetTeams.includes('Alle teams'),
                                onChange: () => handleTeamToggle('Alle teams')
                            }),
                            h('span', null, 'Alle teams')
                        )
                    )
                ),
                h('div', { className: 'form-actions' },
                    h('button', {
                        type: 'button',
                        className: 'btn-cancel',
                        onClick: () => setShowCreateForm(false)
                    }, 'Annuleren'),
                    h('button', {
                        type: 'submit',
                        className: 'btn-submit'
                    }, 'Aanmaken')
                )
            )
        ),

        // Active announcements
        announcements.length > 0 && h('div', { className: 'announcements-list' },
            announcements.map(announcement => 
                h('div', { 
                    key: announcement.ID || announcement.Id,
                    className: 'announcement-item'
                },
                    h('div', { className: 'announcement-content' },
                        h('h4', { className: 'announcement-title' }, announcement.Title),
                        h('div', { 
                            className: 'announcement-description',
                            dangerouslySetInnerHTML: { __html: announcement.Aanvulling || '' }
                        }),
                        h('div', { className: 'announcement-meta' },
                            announcement.DatumTijdStart && h('span', { className: 'announcement-date' },
                                h('i', { className: 'fas fa-calendar' }),
                                ` Vanaf: ${formatDate(announcement.DatumTijdStart)}`
                            ),
                            announcement.DatumTijdEinde && h('span', { className: 'announcement-date' },
                                h('i', { className: 'fas fa-calendar-times' }),
                                ` Tot: ${formatDate(announcement.DatumTijdEinde)}`
                            ),
                            announcement.UitzendenAan && h('span', { className: 'announcement-audience' },
                                h('i', { className: 'fas fa-users' }),
                                ` Voor: ${announcement.UitzendenAan}`
                            )
                        )
                    )
                )
            )
        )
    );
};

export default Mededelingen;

console.log('✅ Mededelingen component loaded successfully.');
