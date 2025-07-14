---
applyTo: '**'
---
# SharePoint Server 2019 On-Premises – REST API Reference

## Environment-context
1. The back-end to our apps are SharePoint Server 2019 On Premises lists.  
2. The base path of our server is: `https://som.org.om.local/sites/`  
3. The specific sub-site I have administrator rights on is `MulderT/`:  
   → `https://som.org.om.local/sites/MulderT/`  
4. We layer our website into several sub-sites to prevent data pollution.  
   Example project site: `https://som.org.om.local/sites/MulderT/Verlof/`  
   We host our `.aspx` files (written mostly in HTML) in libraries. SharePoint only renders `.aspx`.

---

## Scripting context
1. We use the REST API frequently.  
   - Use `/_api/` for request digest headers (CRUD).  
   - Use `/_api/web/` for data queries.  
2. Stack: HTML, CSS, JS (non-JSX), React 18 (via CDN).  
3. React is declared as `h`, using `useState` for reactivity.  
4. Modular code organization — follow **DRY** principle.  
5. ES6 modules used for imports.  
6. Debugging applied when encountering issues.

### React 18 Modern Patterns
- Use `ReactDOM.createRoot()` instead of deprecated `ReactDOM.render()`
- Implement Error Boundaries with class components for error handling
- Use React hooks (useState, useEffect, useMemo, useCallback) for state management
- Structure components with proper lifecycle: imports → state → effects → handlers → render

### Component Architecture Guidelines
Follow this hierarchical pattern for application structure. Be aware that this means our .aspx is at the center of these references:
```
AppWrapper (js/appRoot.js)  
  ↓  
RootApp (js/rootApp.js)  
  ↓  
ValidationLayer (js/validation/{$appname}_VALIDATION.js)  
  ↓  
MainApp (core application logic, e.g., `appLogic`)  
```

### ES6 Module Organization
Structure imports by category and specificity. Sort files by creating a js/ page relative to our .aspx page.

```javascript
// 1. External service imports
import { serviceFunction1, serviceFunction2 } from './services/externalService.js';

// 2. Internal utility imports  
import { utilFunction } from './utils/helperUtils.js';

// 3. Component imports
import ComponentName from './ui/ComponentName.js';

// 4. Config support

// 5. React destructuring
const { createElement: h, useState, useEffect } = React;
```

The documentstructure would be:
```
Verlofrooster.aspx
|_JS
|  |__CoreApp.js
|  |__AppWrapper.js
|  |__Utilities/
|  |        |_{$UtilName}.js
|  |__Services/
|  |__Config/
|  |    |__configLijst.js
|  |__ **OTHER STUFF IN FOLDERS**
|
|__CSS
   |__Verlofrooster_c.css
   |__Verlofrooster_c1.css
```
Carry on this logic.

---

### Error Handling Patterns
- Implement React Error Boundaries for component-level error catching
- Use try/catch blocks for async operations with proper error logging
- Provide fallback UI states for loading and error conditions

---

# REST API – SharePoint Server 2019

## Default structure
```
https://som.org.om.local/sites/MulderT/{$SubSite}/_api
```
Do not duplicate `/api/`. Below are endpoints relative to `/_api/`.

---

## Querying user data
- **Current user:** `/web/currentuser`  
- **Site-users:** `/web/siteusers`  
- **Specific user:** `/web/siteusers(@v)?@v='i:0#.w|domein\\gebruikersnaam'`  
- **Current user's groups:** `/web/currentuser/groups`  

---

## Querying lists and items
- **All lists:** `/web/lists`  
- **Specific list by title:** `/web/lists/GetByTitle('LijstNaam')`  
- **All items in a list:** `/web/lists/GetByTitle('LijstNaam')/items`  
- **Filter + select fields:**  
  `/web/lists/GetByTitle('LijstNaam')/items?$select=Title,Id&$filter=Status eq 'Actief'`  
  <!-- This URL uses query options to return only the Title and Id of list items where Status equals 'Actief'. -->

---

## Creating / Updating / Deleting list items
- **Create item (POST):**  
  `/web/lists/GetByTitle('LijstNaam')/items`  
  <!-- POST a JSON body to this endpoint to create a new list item. -->
- **Update item (MERGE):**  
  `/web/lists/GetByTitle('LijstNaam')/items({ItemID})`  
  <!-- Use headers IF-MATCH with the item's etag and X-HTTP-Method: MERGE to update an existing item. -->
- **Delete item (DELETE):**  
  `/web/lists/GetByTitle('LijstNaam')/items({ItemID})`  
  <!-- Use headers IF-MATCH: * and X-HTTP-Method: DELETE to remove the item regardless of its current etag. -->

### Standard Headers Pattern
For all POST/PUT/MERGE operations, use these headers:
```javascript
const headers = {
    'Accept': 'application/json;odata=verbose',
    'Content-Type': 'application/json;odata=verbose',
    'X-RequestDigest': digestValue
};
```

### Field Name Encoding
SharePoint automatically encodes special characters in field names:
- Spaces become `_x0020_`
- Ampersands (&) become `_x0026_`
- Example: "Status B&S" becomes "Status_x0020_B_x0026_S"
- Always check actual field names in REST responses when debugging

---



## Additional Instructions and Best Practices

### 1. Error Handling
- Always check response status codes (`response.status`) before using `response.json()`.
- Log or handle errors explicitly to avoid silent failures in the front-end.
- **Common SharePoint Error Codes:**
  - 401: Authentication failure - check credentials/session
  - 403: Forbidden - insufficient permissions
  - 404: List/item not found - verify names and existence
  - 413: Request too large - reduce payload size
  - 429: Too many requests - implement throttling
- **Authentication Failures:** Redirect to login or refresh page context
- **Network Timeouts:** Implement retry logic with exponential backoff

### 2. Performance Tips
- Use `$top` to limit large list queries: `?$top=100`
- Use `$orderby` in combination with `$top` when retrieving sorted results.
- Avoid wildcard filters; prefer indexed columns for `$filter`.
- **List View Threshold:** SharePoint limits queries to 5000 items by default
- **Lookup Field Limitations:** Avoid complex lookups; use master key text fields instead
- Use `$orderby` in combination with `$top` when retrieving sorted results.
- Avoid wildcard filters; prefer indexed columns for `$filter`.

### 3. Authentication Context
- Ensure the request is sent with appropriate credentials/cookies (especially when not using JSOM/CSOM).
- When making requests outside the SharePoint domain (e.g., in embedded iframes), verify CORS policy or consider using a proxy.

### 4. Caching & Refreshing
- Avoid unnecessary API calls; cache list metadata or user info if not frequently changing.
- Use `If-None-Match` headers for ETag-based cache validation if available.

### 5. Logging and Debugging
- Consider a `debugMode` toggle in your app to enable console logging of API requests/responses.
- When debugging, log the `X-RequestDigest`, `URL`, and response details.

### 6. Security Considerations
- Never expose admin-level operations or site-relative URLs to users with lower permissions.
- Validate user input before sending to REST endpoints to avoid injection or malformed queries.

### 7. React Component Best Practices
- Use React Error Boundaries to catch and handle JavaScript errors in component trees
- Implement proper loading and error states for all async operations
- Structure component hierarchy with clear separation of concerns (bootstrap → validation → main app → features)
- Use modern React 18 patterns: `ReactDOM.createRoot()`, proper hook dependencies, and concurrent features
- Follow consistent import organization: services → utilities → components → React destructuring

### 8. User Validation and Authentication Flows
- Implement user validation layers that check SharePoint permissions before rendering main application
- Provide clear feedback during authentication and validation processes
- Handle authentication failures gracefully with appropriate fallback UI
- Cache user information and permissions to avoid repeated API calls

---

## Development Workflow & Project Patterns

### 9. File Deployment Process
- Deploy `.aspx` files directly to SharePoint document libraries
- Files contain standard HTML (no SharePoint master page references or .aspx parameters)
- **Development Environment:** Create a 'beta' folder with exact repository replica for testing
- **Testing Lists:** Create secondary SharePoint lists for development/testing purposes
- **File Editing:** Use network drive mapping to edit files directly with external editors (e.g., Notepad++)

### 10. Coding Standards & Conventions
- **Variable/Function Naming:** Use Dutch names in kebab-case style (e.g., `gebruiker-naam`, `laad-verlof-data`)
- **React Component Structure:** Follow hierarchical pattern with clear separation of concerns
- **CSS Organization:** 
  - Store in `/css` subfolder
  - Single file approach: `{appName}_style.css` (max ~1500 lines)
  - Additional files: `{appName}_style2.css`, `{appName}_style3.css` etc.
  - Load CSS files in numerical order

### 11. Data Modeling Patterns
- **List Structure:** Define structure on-demand based on application needs
- **Configuration:** Always provide necessary data structure like configLijst.js
- **Relationships:** Use master key text fields instead of SharePoint lookup fields
- **Common Field Types:** Dropdown menus, boolean sliders, single line text, memo fields
- **Data Holders:** Create common data holder components to manage relationships between lists

### 12. Testing & Browser Support
- **Testing Approach:** Test directly against live SharePoint data (avoid mock data)
- **Error Preference:** Show real errors rather than fake mock data responses
- **Browser Support:** Mandatory support for Microsoft Edge and Google Chrome
- **Development Testing:** Use beta folder environment with secondary test lists

---





_DISREGARD THE FOLLOWING INFO AS IT NOT YET WORKED OUT_

# 3. Utilities
## 3.1: Sending notification e-mail
  - **Endpoint:** `/SP.Utilities.Utility.SendEmail` 

## 3.2: List set-up for aggregated/timed messages:
  - **List path:** `/lists/GetByTitle('EmailNotifications')`
  - Columns: 
    - `Title` (auto-generated ID)
    - `Addressee` (Person field - who should receive the email)
    - `eMailSent` (Boolean - default: false)
    - `AggregatedMessage` (Multi-line text - notification content)
    - `eMailReceiver` (Single line text - email address)
    - `CreatedDate` (DateTime - when notification was created)
    - `ProcessedDate` (DateTime - when email was sent)
    - `ProcessedBy` (Person field - who triggered the email)
    - `RetryCount` (Number - track failed attempts)

## 3.3. Improved Logic for Sending Procedure

### 3.3.1. List-item creation:
  - Users add a list-item to the list via form submission
  - Set `eMailSent` value to `False` (default)
  - Add user input as summary to `AggregatedMessage`
  - Fetch recipient email by querying user profile: `/web/siteusers/getByEmail('user@domain.com')`
  - Store email address in `eMailReceiver` field

### 3.3.2. Enhanced Trigger-event with Safety Measures

**Trigger Conditions:**
- Only specific authorized users (admin/manager role) can trigger email processing
- Implement session-based lock to prevent duplicate processing
- Add processing timestamp to prevent concurrent execution

**Page Load Logic:**
```javascript
// Check if current user has permission to process emails
if (!hasEmailProcessingPermission()) {
    return; // Exit early for unauthorized users
}

// Check for existing processing lock (prevent concurrent execution)
if (isProcessingLocked()) {
    console.log('Email processing already in progress');
    return;
}

// Set processing lock
setProcessingLock(true);

try {
    await processEmailNotifications();
} finally {
    // Always release lock
    setProcessingLock(false);
}
```

**Enhanced getDagTijd Function:**
```javascript
async function processEmailNotifications() {
    // Get server time (more reliable than client time)
    const serverTime = await getSharePointServerTime();
    const currentHour = serverTime.getHours();
    
    // Only process between 15:00 and 23:59 to prevent accidental sends
    if (currentHour < 15) {
        console.log('Too early for email processing (before 15:00)');
        return;
    }
    
    // Check for unsent notifications
    const unsentNotifications = await queryUnsentNotifications();
    
    if (unsentNotifications.length === 0) {
        console.log('No unsent notifications found');
        return;
    }
    
    // Group notifications by recipient
    const groupedNotifications = groupNotificationsByRecipient(unsentNotifications);
    
    // Process each recipient group
    for (const [recipient, notifications] of groupedNotifications) {
        try {
            await sendAggregatedEmail(recipient, notifications);
            await markNotificationsAsSent(notifications);
        } catch (error) {
            await incrementRetryCount(notifications);
            console.error(`Failed to send email to ${recipient}:`, error);
        }
    }
}
```

### 3.3.3. Additional Safety Measures

**Error Handling & Retry Logic:**
- Track failed email attempts with `RetryCount` field
- Implement exponential backoff for retries
- Set maximum retry limit (e.g., 3 attempts)
- Log all email processing activities

**Validation & Security:**
- Validate email addresses before sending
- Sanitize message content to prevent injection
- Check user permissions before processing
- Implement rate limiting to prevent spam

**Monitoring & Logging:**
- Create audit trail of all email processing
- Monitor for failed sends and investigate
- Set up alerts for processing errors
- Track email delivery success rates

### 3.3.4. Alternative Trigger Mechanisms

**Option 1: Admin Dashboard Trigger**
- Create dedicated admin page for email processing
- Manual trigger button with confirmation dialog
- Better control over when emails are sent

**Option 2: Scheduled via External Service**
- Use Power Automate flow (if available)
- Set up daily trigger at specified time
- More reliable than page-load dependency

**Option 3: Background Processing Flag**
- Use a configuration list to enable/disable processing
- Reduces dependency on specific user actions
- Allows for maintenance mode during updates
