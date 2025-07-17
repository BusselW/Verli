
const { createElement: h, useState, useEffect } = React;
import { getListItems } from './dataService.js';

const BlokkenMonitor = () => {
    const [counts, setCounts] = useState({
        verlof: 0,
        compensatie: 0,
        zittingsvrij: 0,
    });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchCounts = async () => {
            try {
                const today = new Date();
                const firstDay = new Date(today.getFullYear(), today.getMonth(), 1).toISOString();
                const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString();

                const [verlofItems, compensatieItems, zittingsvrijItems] = await Promise.all([
                    getListItems('Verlof', 'Id', `StartDatum ge '${firstDay}' and EindDatum le '${lastDay}'`),
                    getListItems('CompensatieUren', 'Id', `StartCompensatieUren ge '${firstDay}' and EindeCompensatieUren le '${lastDay}'`),
                    getListItems('IncidenteelZittingVrij', 'Id', `ZittingsVrijeDagTijd ge '${firstDay}' and ZittingsVrijeDagTijdEind le '${lastDay}'`)
                ]);

                setCounts({
                    verlof: verlofItems.length,
                    compensatie: compensatieItems.length,
                    zittingsvrij: zittingsvrijItems.length,
                });
            } catch (error) {
                console.error("Error fetching block counts:", error);
            } finally {
                setLoading(false);
            }
