const { createElement: h, useState, useEffect } = React;
import { getListItems } from './dataService.js';

const BlokkenMonitor = () => {
    const [counts, setCounts] = useState({
        verlof: 0,
        compensatie: 0,
        zittingsvrij: 0,
    });
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchBlokkenCounts = async () => {
            try {
                setLoading(true);
                setError(null);

                const today = new Date();
                // Set to the first day of the current month, 00:00:00.000
                const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
                // Set to the last day of the current month, 23:59:59.999
                const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0, 23, 59, 59, 999);

                // SharePoint REST API expects ISO 8601 format without milliseconds for date comparisons
                // Using toISOString() and then slicing to 'YYYY-MM-DD' is generally safe for date-only comparisons
                // For DateTime fields, SharePoint expects full ISO string including time and 'Z' for UTC
                // However, for filtering a full day, 'ge YYYY-MM-DD' and 'le YYYY-MM-DD' works for date fields
                // For DateTime fields, it's safer to use the full ISO string for start and end of day
                const formatSharePointDateTime = (date) => date.toISOString();

                const filterStart = formatSharePointDateTime(firstDayOfMonth);
                const filterEnd = formatSharePointDateTime(lastDayOfMonth);

                // Constructing the filter query for date ranges
                // For 'Verlof' and 'CompensatieUren', assuming StartDatum/EindDatum are DateTime fields
                // For 'IncidenteelZittingVrij', assuming ZittingsVrijeDagTijd/ZittingsVrijeDagTijdEind are DateTime fields
                const dateRangeFilter = (startField, endField) => 
                    `${startField} ge datetime'${filterStart}' and ${endField} le datetime'${filterEnd}'`;

                const [verlofItems, compensatieItems, zittingsvrijItems] = await Promise.all([
                    getListItems('Verlof', 'Id', dateRangeFilter('StartDatum', 'EindDatum')),
                    getListItems('CompensatieUren', 'Id', dateRangeFilter('StartCompensatieUren', 'EindeCompensatieUren')),
                    getListItems('IncidenteelZittingVrij', 'Id', dateRangeFilter('ZittingsVrijeDagTijd', 'ZittingsVrijeDagTijdEind'))
                ]);

                setCounts({
                    verlof: verlofItems.length,
                    compensatie: compensatieItems.length,
                    zittingsvrij: zittingsvrijItems.length,
                });
            } catch (err) {
                console.error("Fout bij ophalen blokken tellingen:", err);
                setError("Fout bij het laden van blokken tellingen: " + err.message);
            } finally {
                setLoading(false);
            }
        };

        fetchBlokkenCounts();
    }, []); // Empty dependency array means this effect runs once on mount

    if (loading) {
        return h('div', { className: 'admin-tab-panel admin-tab-active', style: { textAlign: 'center', padding: '3rem' } },
            h('div', { className: 'loading-spinner' }),
            h('p', null, 'Blokken tellingen laden...')
        );
    }

    if (error) {
        return h('div', { className: 'admin-tab-panel admin-tab-active', style: { textAlign: 'center', padding: '3rem', color: 'var(--danger)' } },
            h('i', { className: 'fas fa-exclamation-triangle', style: { fontSize: '2rem', marginBottom: '1rem' } }),
            h('h3', null, 'Fout bij het laden'),
            h('p', null, error)
        );
    }

    return h('div', { className: 'admin-tab-panel admin-tab-active', id: 'monitoring-content' },
        h('fieldset', null,
            h('legend', null, 'Blokken Monitor (Huidige Maand)'),
            h('div', { style: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '1rem' } },
                h('div', { className: 'count-card', style: { padding: '1rem', backgroundColor: 'var(--bg-secondary)', border: '1px solid var(--border)', borderRadius: '0.5rem', textAlign: 'center' } },
                    h('h4', { style: { margin: '0 0 0.5rem', fontSize: '0.875rem', color: 'var(--text-secondary)' } }, 'Verlof Aanvragen'),
                    h('p', { style: { margin: '0', fontSize: '2rem', fontWeight: '700', color: 'var(--text-primary)' } }, counts.verlof)
                ),
                h('div', { className: 'count-card', style: { padding: '1rem', backgroundColor: 'var(--bg-secondary)', border: '1px solid var(--border)', borderRadius: '0.5rem', textAlign: 'center' } },
                    h('h4', { style: { margin: '0 0 0.5rem', fontSize: '0.875rem', color: 'var(--text-secondary)' } }, 'Compensatie-uren'),
                    h('p', { style: { margin: '0', fontSize: '2rem', fontWeight: '700', color: 'var(--text-primary)' } }, counts.compensatie)
                ),
                h('div', { className: 'count-card', style: { padding: '1rem', backgroundColor: 'var(--bg-secondary)', border: '1px solid var(--border)', borderRadius: '0.5rem', textAlign: 'center' } },
                    h('h4', { style: { margin: '0 0 0.5rem', fontSize: '0.875rem', color: 'var(--text-secondary)' } }, 'Zittingsvrij Dagen'),
                    h('p', { style: { margin: '0', fontSize: '2rem', fontWeight: '700', color: 'var(--text-primary)' } }, counts.zittingsvrij)
                )
            )
        )
    );
};

export default BlokkenMonitor;