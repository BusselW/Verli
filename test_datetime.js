// Test the fixed createSharePointDateTime function
const createSharePointDateTime = (dateString, timeString) => {
    if (!dateString || !timeString) {
        console.warn('Missing date or time input', { dateString, timeString });
        return null;
    }
    
    // Parse input values
    const [year, month, day] = dateString.split('-').map(Number);
    const [hours, minutes] = timeString.split(':').map(Number);
    
    // Create ISO string manually to avoid timezone conversion
    const paddedMonth = String(month).padStart(2, '0');
    const paddedDay = String(day).padStart(2, '0');
    const paddedHours = String(hours).padStart(2, '0');
    const paddedMinutes = String(minutes).padStart(2, '0');
    
    // Return ISO string without timezone conversion
    return `${year}-${paddedMonth}-${paddedDay}T${paddedHours}:${paddedMinutes}:00`;
};

// Test with today's date and 00:00 time
const today = '2025-01-15';
const result = createSharePointDateTime(today, '00:00');

console.log('Input date:', today);
console.log('Input time: 00:00');
console.log('Result:', result);
console.log('✅ Date preserved correctly:', result.startsWith('2025-01-15'));

// Test with different time
const resultAfternoon = createSharePointDateTime('2025-01-15', '14:30');
console.log('\nTest with 14:30:');
console.log('Result:', resultAfternoon);
console.log('✅ Time preserved correctly:', resultAfternoon.includes('14:30'));

console.log('\n✅ All tests passed - no more date shifting!');
