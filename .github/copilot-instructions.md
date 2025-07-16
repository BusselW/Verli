# Copilot Instructions for Verlofrooster Application

## Project Overview
This is a Dutch employee scheduling and leave management system built on SharePoint with React components. The application manages vacation requests ("verlof"), compensation hours ("compensatie-uren"), shift scheduling, and team management for organizations.

## Architecture & Key Patterns

### Application Structure
- **Main App**: `verlofRooster.aspx` - Primary calendar/scheduling interface
- **Sub-modules**: Organized in `pages/` directory (adminCentrum, behandelCentrum, beheerCentrum, etc.)
- **Configuration**: Centralized SharePoint list definitions in `js/config/configLijst.js`
- **UI Components**: React components in `js/ui/` with corresponding CSS in `css/`

### SharePoint Integration Patterns
```javascript
// Always use the centralized configuration system
const config = window.getLijstConfig('Verlof'); // Get list config
const siteUrl = window.ConfigHelper.getSiteUrl(); // Get site URL

// SharePoint CRUD operations use configLijst.js definitions
const verlofData = {
    Title: `Verlofaanvraag - ${employeeName} - ${date}`,
    MedewerkerID: username, // Always domain\username format
    StartDatum: createSharePointDateTime(date, time),
    Status: 'Nieuw' // Use StatuslijstOpties values
};
```

### Modern UI Design System
The application follows a specific design language with:
- **Typography**: Inter font family, professional hierarchy
- **Colors**: Blue primary (#1e3a8a), Orange accent (#FF6D22), Status-based colors
- **Layout**: Container-based with floating headers, sticky navigation
- **Forms**: Floating label inputs, modern toggle switches, consistent spacing

### Form Component Patterns
```javascript
// Use React hooks with centralized validation
const [fieldValue, setFieldValue] = useState('');
const [isSubmitting, setIsSubmitting] = useState(false);

// Always validate permissions before submission
const validation = await validateFormSubmission(formData, operation);
if (!validation.valid) {
    showCRUDRestrictionMessage(operation, validation.errors.join(', '));
    return;
}
```

## Critical Implementation Guidelines

### SharePoint List Integration
- **Never hardcode list IDs** - always use `getLijstConfig(listName)`
- **Field mapping**: Use `interneNaam` for SharePoint operations, `titel` for display
- **DateTime handling**: Use `createSharePointDateTime()` utility for consistent formatting
- **User identification**: Always store as `domain\username` format in MedewerkerID fields

### React Component Structure
```javascript
// Standard component export pattern
import { createElement as h, useState, useEffect } from '../../path/to/react';

const MyComponent = ({ onSubmit, onClose, initialData = {} }) => {
    // Component logic here
    return h('div', { className: 'component-container' }, 
        // JSX-like structure using createElement
    );
};

export default MyComponent;
```

### CSS Class Conventions
- **Forms**: `.form-container`, `.form-row`, `.form-groep`, `.form-input`, `.form-select`
- **Buttons**: `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-danger`
- **Layout**: `.header`, `.toolbar`, `.main-content`, `.sticky-header-container`
- **States**: `.loading`, `.disabled`, `.readonly-field`, `.selected`

### Permission System
```javascript
// Check permissions before showing UI elements
const canManage = await canManageOthersEvents();
const hasAccess = await hasAdminAccess();

// Use permission-aware rendering
canManage ? 
    h('select', { /* full control */ }) : 
    h('input', { readOnly: true, /* limited view */ })
```

## Development Workflows

### Adding New Features
1. **Configuration**: Add list definitions to `configLijst.js` if new SharePoint lists needed
2. **Services**: Create/update service files in `js/services/` for data operations
3. **UI Components**: Build React components in `js/ui/` following existing patterns
4. **Styling**: Use the established CSS class system and design tokens
5. **Permission Integration**: Always implement proper access controls

### Form Development
1. Start with existing form templates (`VerlofAanvraagForm.js`, `CompensatieUrenForm.js`)
2. Use floating label inputs and consistent validation patterns
3. Implement permission-based field visibility
4. Follow the submit/validation workflow with `validateFormSubmission()`

### Debugging
- **SharePoint Errors**: Check browser network tab for REST API responses
- **Configuration Issues**: Verify `getLijstConfig()` returns expected data
- **Permission Problems**: Check user groups and `gemachtigdenLijst` configuration
- **Form Validation**: Look for `validateFormSubmission()` and CRUD restriction messages

## Key Files to Reference

### Core Configuration
- `js/config/configLijst.js` - SharePoint list definitions and app configuration
- `js/config/configHelper.js` - Helper functions for configuration access
- `pages/config/confPages.js` - Common page components and navigation

### Service Layer
- `js/services/sharepointService.js` - Core SharePoint operations
- `js/services/permissionService.js` - User permission management
- `js/services/crudPermissionService.js` - Form validation and restrictions

### UI Components
- `js/ui/forms/` - Form components for different data types
- `js/ui/Modal.js` - Reusable modal component
- `js/ui/NotificationSystem.js` - Toast notifications

### Styling
- `css/verlofrooster.css` - Main application styles
- `css/verlofrooster_s.css` - Form and component styles

## Domain Knowledge
- **Verlof**: Vacation/leave requests with approval workflow
- **Compensatie-uren**: Overtime compensation and shift swapping
- **Zittingsvrij**: Court-free periods for legal personnel
- **Teams**: Organizational units with team leaders and permissions
- **Medewerkers**: Employee master data with working schedules

When implementing new features, always consider the permission model, follow the established SharePoint integration patterns, and maintain consistency with the modern UI design system.
