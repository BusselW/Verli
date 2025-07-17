<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SharePoint File Check-In Utility</title>
    <!-- Chosen Palette: Corporate Calm (Slate Gray, Soft Blue, Off-White) -->
    <!-- Application Structure Plan: The application uses a task-oriented, single-view structure. The user is guided through a linear workflow: 1. Specify the target library. 2. View and edit the relevant files in an interactive table. 3. Execute the batch check-in. This structure was chosen because it directly mirrors the user's goal, eliminating navigation and focusing entirely on the task at hand. All necessary controls and information are presented in a single, responsive view for maximum efficiency. -->
    <!-- Visualization & Content Choices: Source Info: List of checked-out files and their metadata. -> Goal: Allow batch editing and processing. -> Presentation Method: An interactive HTML table rendered by React. -> Interaction: Users edit metadata directly in input fields within the table rows. A single 'Save & Check-In All' button initiates the batch process. -> Justification: A table is the universally understood and most efficient way to display and interact with structured row-based data. In-line editing removes the need for modals or separate pages, streamlining the workflow. -> Library/Method: React for dynamic rendering, HTML/Tailwind for the table structure. -->
    <!-- CONFIRMATION: NO SVG graphics used. NO Mermaid JS used. -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <style>
        body {
            background-color: #f8fafc; /* Tailwind gray-50 */
        }
        .table-container {
            overflow-x: auto;
        }
        .status-info { background-color: #e0f2fe; border-left-color: #38bdf8; }
        .status-success { background-color: #dcfce7; border-left-color: #4ade80; }
        .status-error { background-color: #fee2e2; border-left-color: #f87171; }
        .url-prefix {
            flex-shrink: 0;
        }
    </style>
</head>
<body>

    <div id="root"><div class="p-4 text-center text-gray-600">Initializing SharePoint context...</div></div>

    <script type="text/babel">
        const { useState, useEffect, useCallback } = React;

        // Reusable component for each search section
        const FileFinder = ({ searchMode, title, description, requestDigest, getBaseSiteUrl }) => {
            const [subsitePath, setSubsitePath] = useState('');
            const [libraryName, setLibraryName] = useState('');
            const [includeSubfolders, setIncludeSubfolders] = useState(true);
            const [files, setFiles] = useState([]);
            const [originalFiles, setOriginalFiles] = useState([]);
            const [isLoading, setIsLoading] = useState(false);
            const [status, setStatus] = useState({ message: '', type: 'info' });

            const handleFetchFiles = async () => {
                if (!libraryName) {
                    setStatus({ message: 'Please enter a Library Name.', type: 'error' });
                    return;
                }
                setIsLoading(true);
                setFiles([]);
                setOriginalFiles([]);
                setStatus({ message: 'Querying library...', type: 'info' });

                if (!requestDigest) {
                    setStatus({ message: 'Authentication token not ready. Please wait a moment and try again.', type: 'error' });
                    setIsLoading(false);
                    return;
                }

                try {
                    let cleanSubsitePath = subsitePath.trim();
                    if (cleanSubsitePath.toLowerCase().startsWith('http')) {
                        const urlObject = new URL(cleanSubsitePath);
                        cleanSubsitePath = urlObject.pathname;
                    }
                    if (cleanSubsitePath && !cleanSubsitePath.startsWith('/')) {
                        cleanSubsitePath = '/' + cleanSubsitePath;
                    }
                    if (cleanSubsitePath.endsWith('/')) {
                        cleanSubsitePath = cleanSubsitePath.slice(0, -1);
                    }
                    if (cleanSubsitePath === '/') {
                        cleanSubsitePath = ''; // Root site case
                    }

                    const cleanLibraryName = libraryName.trim();
                    const baseSiteUrl = getBaseSiteUrl();
                    const webUrl = baseSiteUrl + cleanSubsitePath;
                    
                    // Fix folder path construction - use proper SharePoint relative URL format
                    const folderPath = cleanSubsitePath + '/' + cleanLibraryName;

                    // Get current user for filtering checked out files
                    const currentUserResponse = await fetch(`${webUrl}/_api/web/currentUser`, {
                        headers: { 'Accept': 'application/json;odata=verbose' }
                    });
                    
                    if (!currentUserResponse.ok) {
                        throw new Error(`Failed to get current user: ${currentUserResponse.status} ${currentUserResponse.statusText}`);
                    }
                    
                    const currentUserData = await currentUserResponse.json();
                    const currentUserId = currentUserData.d.Id;

                    // Construct CAML query based on search mode
                    let whereClause = '';
                    if (searchMode === 'checkedOut') {
                        whereClause = `
                            <Where>
                                <And>
                                    <IsNotNull><FieldRef Name='CheckoutUser' /></IsNotNull>
                                    <Eq>
                                        <FieldRef Name='CheckoutUser' LookupId='TRUE' />
                                        <Value Type='Integer'>${currentUserId}</Value>
                                    </Eq>
                                </And>
                            </Where>
                        `;
                    }

                    const camlQuery = `
                        <View Scope="${includeSubfolders ? 'RecursiveAll' : 'FilesOnly'}">
                            <Query>${whereClause}</Query>
                            <ViewFields>
                                <FieldRef Name='ID' />
                                <FieldRef Name='FileLeafRef' />
                                <FieldRef Name='FileRef' />
                                <FieldRef Name='Title' />
                                <FieldRef Name='Category' />
                                <FieldRef Name='CheckoutUser' />
                                <FieldRef Name='File_x0020_Type' />
                            </ViewFields>
                            <RowLimit>5000</RowLimit>
                        </View>
                    `;

                    const queryPayload = {
                        'query': {
                            '__metadata': { 'type': 'SP.CamlQuery' },
                            'ViewXml': camlQuery
                        }
                    };
                    
                    // Don't set FolderServerRelativeUrl unless we have a specific folder
                    if (folderPath && folderPath !== '/') {
                        queryPayload.query.FolderServerRelativeUrl = folderPath;
                    }

                    // Execute the query to get files from the document library
                    const apiUrl = `${webUrl}/_api/web/lists/GetByTitle('${cleanLibraryName}')/GetItems`;
                    const response = await fetch(apiUrl, {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json;odata=verbose',
                            'Content-Type': 'application/json;odata=verbose',
                            'X-RequestDigest': requestDigest
                        },
                        body: JSON.stringify(queryPayload)
                    });

                    if (!response.ok) {
                        let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
                        
                        try {
                            const errorData = await response.json();
                            if (errorData.error && errorData.error.message) {
                                errorMessage = errorData.error.message.value || errorData.error.message;
                            }
                        } catch (e) {
                            // If we can't parse the error JSON, use the status text
                        }
                        
                        // Provide helpful error messages for common issues
                        if (response.status === 404) {
                            errorMessage = `Library '${cleanLibraryName}' not found in the specified location. Please verify the library name and subsite path.`;
                        } else if (response.status === 403) {
                            errorMessage = `Access denied to library '${cleanLibraryName}'. Please verify you have permission to access this library.`;
                        }
                        
                        throw new Error(errorMessage);
                    }

                    const data = await response.json();
                    const allFoundFiles = data.d.results.map(item => ({
                        id: item.Id,
                        name: item.FileLeafRef,
                        serverRelativeUrl: item.FileRef,
                        listItemEntityTypeFullName: item.__metadata.type,
                        listTitle: cleanLibraryName,
                        isEditable: item.CheckoutUser && item.CheckoutUser.LookupId === currentUserId,
                        title: item.Title || '',
                        category: item.Category || '',
                        fileType: item.File_x0020_Type || ''
                    }));

                    if (allFoundFiles.length === 0) {
                        const searchType = searchMode === 'checkedOut' ? 'checked-out files' : 'files';
                        setStatus({ message: `No ${searchType} were found in this library location.`, type: 'info' });
                    } else {
                        const searchType = searchMode === 'checkedOut' ? 'checked-out file(s)' : 'file(s)';
                        setStatus({ message: `Search complete. Found ${allFoundFiles.length} ${searchType}.`, type: 'success' });
                    }

                    setFiles(allFoundFiles);
                    setOriginalFiles(JSON.parse(JSON.stringify(allFoundFiles)));

                } catch (error) {
                    setStatus({ message: `Error: ${error.message}`, type: 'error' });
                    console.error("Detailed Error:", error);
                } finally {
                    setIsLoading(false);
                }
            };
            
            const handleMetadataChange = (fileId, field, value) => {
                const updatedFiles = files.map(file => {
                    if (file.id === fileId) {
                        return { ...file, [field]: value };
                    }
                    return file;
                });
                setFiles(updatedFiles);
            };

            const handleCheckInAll = async () => {
                setIsLoading(true);
                
                const changedAndEditableFiles = files.filter(file => {
                    if (!file.isEditable) return false;
                    const originalFile = originalFiles.find(orig => orig.id === file.id);
                    return !originalFile || originalFile.title !== file.title || originalFile.category !== file.category;
                });

                if (changedAndEditableFiles.length === 0) {
                    setStatus({ message: 'No editable files have been changed.', type: 'info' });
                    setIsLoading(false);
                    return;
                }
                
                setStatus({ message: `Starting check-in process for ${changedAndEditableFiles.length} file(s)...`, type: 'info' });

                let successCount = 0;
                const baseSiteUrl = getBaseSiteUrl();

                for (const file of changedAndEditableFiles) {
                    try {
                        setStatus({ message: `Updating metadata for ${file.name}...`, type: 'info' });
                        
                        const listTitle = file.listTitle;
                        if (!listTitle) {
                            throw new Error(`Could not determine List Name for file ${file.name}.`);
                        }
                        
                        // Better logic to determine the subsite path from the file URL
                        let fileSubsitePath = '';
                        const basePath = new URL(baseSiteUrl).pathname;
                        const fullPath = file.serverRelativeUrl;
                        
                        // Find the library name in the path to determine the subsite
                        const libraryIndex = fullPath.toLowerCase().indexOf('/' + listTitle.toLowerCase() + '/');
                        if (libraryIndex !== -1) {
                            fileSubsitePath = fullPath.substring(0, libraryIndex);
                        } else {
                            // Fallback: use the current subsite path
                            fileSubsitePath = subsitePath || '';
                        }
                        
                        const webUrl = baseSiteUrl + fileSubsitePath;

                        const updateUrl = `${webUrl}/_api/web/lists/GetByTitle('${listTitle}')/items(${file.id})`;
                        
                        const updateResponse = await fetch(updateUrl, {
                            method: 'POST',
                            headers: {
                                'Accept': 'application/json;odata=verbose',
                                'Content-Type': 'application/json;odata=verbose',
                                'X-RequestDigest': requestDigest,
                                'X-HTTP-Method': 'MERGE',
                                'IF-MATCH': '*'
                            },
                            body: JSON.stringify({
                                '__metadata': { 'type': file.listItemEntityTypeFullName },
                                'Title': file.title,
                                'Category': file.category
                            })
                        });

                        if (!updateResponse.ok) {
                            let errorMessage = `HTTP ${updateResponse.status}: ${updateResponse.statusText}`;
                            try {
                                const errorData = await updateResponse.json();
                                if (errorData.error && errorData.error.message) {
                                    errorMessage = errorData.error.message.value || errorData.error.message;
                                }
                            } catch (e) {
                                // Use status text if can't parse error
                            }
                            throw new Error(`Failed to update metadata for ${file.name}: ${errorMessage}`);
                        }
                        
                        setStatus({ message: `Checking in ${file.name}...`, type: 'info' });
                        const checkInUrl = `${webUrl}/_api/web/GetFileByServerRelativeUrl('${file.serverRelativeUrl}')/checkin(comment='Checked in via utility.',checkintype=1)`;
                        const checkInResponse = await fetch(checkInUrl, {
                            method: 'POST',
                            headers: {
                                'Accept': 'application/json;odata=verbose',
                                'X-RequestDigest': requestDigest,
                            }
                        });

                        if (!checkInResponse.ok) {
                            let checkInErrorMessage = `HTTP ${checkInResponse.status}: ${checkInResponse.statusText}`;
                            try {
                                const errorData = await checkInResponse.json();
                                if (errorData.error && errorData.error.message) {
                                    checkInErrorMessage = errorData.error.message.value || errorData.error.message;
                                }
                            } catch (e) {
                                // Use status text if can't parse error
                            }
                            throw new Error(`Failed to check in ${file.name}: ${checkInErrorMessage}`);
                        }
                        
                        successCount++;

                    } catch (error) {
                        setStatus({ message: `An error occurred with ${file.name}: ${error.message}. Halting process.`, type: 'error' });
                        setIsLoading(false);
                        return;
                    }
                }
                
                setStatus({ message: `Successfully checked in ${successCount} of ${changedAndEditableFiles.length} file(s).`, type: 'success' });
                setIsLoading(false);
                handleFetchFiles();
            };
            
            const hasChanges = files.some(file => {
                if (!file.isEditable) return false;
                const originalFile = originalFiles.find(orig => orig.id === file.id);
                return !originalFile || originalFile.title !== file.title || originalFile.category !== file.category;
            });

            return (
                <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
                    <div className="flex justify-between items-start">
                        <div>
                            <h2 className="text-xl font-semibold text-gray-700">{title}</h2>
                            <p className="mt-2 text-gray-500">{description}</p>
                        </div>
                        <button 
                            onClick={handleCheckInAll}
                            disabled={isLoading || !hasChanges}
                            className="ml-4 flex-shrink-0 w-full sm:w-auto px-6 py-3 text-white font-semibold rounded-md shadow-sm transition-colors duration-200 disabled:bg-gray-400 disabled:cursor-not-allowed enabled:bg-blue-600 enabled:hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                        >
                            {isLoading ? 'Processing...' : 'Save & Check-In Changes'}
                        </button>
                    </div>

                    <LibrarySelector 
                        baseSiteUrl={getBaseSiteUrl()}
                        subsitePath={subsitePath}
                        setSubsitePath={setSubsitePath}
                        libraryName={libraryName}
                        setLibraryName={setLibraryName}
                        includeSubfolders={includeSubfolders}
                        setIncludeSubfolders={setIncludeSubfolders}
                        onFetchFiles={handleFetchFiles}
                        isLoading={isLoading}
                    />

                    {status.message && <StatusBar message={status.message} type={status.type} />}

                    {files.length > 0 && (
                        <FileTable files={files} onMetadataChange={handleMetadataChange} />
                    )}
                </div>
            );
        };

        const App = ({ baseSiteUrl, requestDigest }) => {
            const getBaseSiteUrl = () => baseSiteUrl;

            return (
                <div className="min-h-screen bg-gray-50 text-gray-800 font-sans p-4 sm:p-6 lg:p-8">
                    <div className="max-w-7xl mx-auto">
                        <header className="pb-4 border-b border-gray-200 mb-8">
                             <h1 className="text-3xl font-bold text-gray-900">SharePoint File Check-In Utility</h1>
                             <p className="mt-1 text-gray-600">Quickly find, update, and check in your checked-out files.</p>
                        </header>
                        
                        <main className="space-y-8">
                            <FileFinder
                                searchMode="checkedOut"
                                title="1. Find Files Checked-Out To You"
                                description="Enter a subsite path and library name to find files currently checked out by you."
                                requestDigest={requestDigest}
                                getBaseSiteUrl={getBaseSiteUrl}
                            />

                            <FileFinder
                                searchMode="all"
                                title="2. Find All Files in a Library"
                                description="Enter a subsite path and library name to view all files. You can only edit files checked out to you."
                                requestDigest={requestDigest}
                                getBaseSiteUrl={getBaseSiteUrl}
                            />
                        </main>
                    </div>
                </div>
            );
        };

        const LibrarySelector = ({ baseSiteUrl, subsitePath, setSubsitePath, libraryName, setLibraryName, includeSubfolders, setIncludeSubfolders, onFetchFiles, isLoading }) => (
            <div className="mt-4 space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                     <div>
                        <label htmlFor="subsitePath" className="block text-sm font-medium text-gray-700">Subsite Path</label>
                        <div className="mt-1 flex shadow-sm rounded-md">
                            <span className="inline-flex items-center px-3 rounded-l-md border border-r-0 border-gray-300 bg-gray-100 text-gray-500 text-sm">
                                {baseSiteUrl}
                            </span>
                            <input
                                id="subsitePath"
                                type="text"
                                value={subsitePath}
                                onChange={(e) => setSubsitePath(e.target.value)}
                                placeholder="/sites/YourSubsite"
                                className="flex-grow p-3 border border-gray-300 rounded-r-md focus:ring-blue-500 focus:border-blue-500"
                                disabled={isLoading}
                            />
                        </div>
                    </div>
                    <div>
                        <label htmlFor="libraryName" className="block text-sm font-medium text-gray-700">Library Name</label>
                        <input
                            id="libraryName"
                            type="text"
                            value={libraryName}
                            onChange={(e) => setLibraryName(e.target.value)}
                            placeholder="Documents"
                            className="mt-1 w-full p-3 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                            disabled={isLoading}
                        />
                    </div>
                </div>
                <div className="flex items-center justify-between">
                    <div className="flex items-center">
                        <input
                            id="subfolders"
                            name="subfolders"
                            type="checkbox"
                            checked={includeSubfolders}
                            onChange={(e) => setIncludeSubfolders(e.target.checked)}
                            disabled={isLoading}
                            className="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                        />
                        <label htmlFor="subfolders" className="ml-2 block text-sm text-gray-900">
                            Include Sub-folders
                        </label>
                    </div>
                    <button 
                        onClick={onFetchFiles}
                        disabled={isLoading}
                        className="px-6 py-3 bg-gray-700 text-white font-semibold rounded-md shadow-sm hover:bg-gray-800 transition-colors duration-200 disabled:bg-gray-400 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
                    >
                        {isLoading ? 'Loading...' : 'Load Files'}
                    </button>
                </div>
            </div>
        );

        const StatusBar = ({ message, type }) => {
            const typeClasses = `status-${type}`;
            return (
                <div className={`mt-6 p-4 border-l-4 rounded-r-lg ${typeClasses} text-gray-700`} role="alert">
                    <p className="font-medium">{message}</p>
                </div>
            );
        };

        const FileTable = ({ files, onMetadataChange }) => (
            <div className="mt-6 table-container">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">File Name</th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Full Path</th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title (Required)</th>
                            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Category (Required)</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {files.map(file => (
                            <FileRow key={file.id} file={file} onMetadataChange={onMetadataChange} />
                        ))}
                    </tbody>
                </table>
            </div>
        );

        const FileRow = ({ file, onMetadataChange }) => (
            <tr>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{file.name}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{file.serverRelativeUrl}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                    <input
                        type="text"
                        value={file.title}
                        onChange={(e) => onMetadataChange(file.id, 'title', e.target.value)}
                        disabled={!file.isEditable}
                        className="w-full p-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
                    />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                     <input
                        type="text"
                        value={file.category}
                        onChange={(e) => onMetadataChange(file.id, 'category', e.target.value)}
                        disabled={!file.isEditable}
                        className="w-full p-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
                    />
                </td>
            </tr>
        );

        function initializeAndStartApp() {
            // This function runs once the DOM is ready.
            // Try to get the context info from the current site
            const contextPaths = ['./_api/contextinfo', '/_api/contextinfo'];
            
            async function tryFetchContext() {
                for (const path of contextPaths) {
                    try {
                        const response = await fetch(path, {
                            method: 'POST',
                            headers: { 'Accept': 'application/json;odata=verbose' }
                        });
                        
                        if (response.ok) {
                            const data = await response.json();
                            const requestDigest = data.d.GetContextWebInformation.FormDigestValue;
                            const siteFullUrl = data.d.GetContextWebInformation.SiteFullUrl;
                            const root = ReactDOM.createRoot(document.getElementById('root'));
                            root.render(<App baseSiteUrl={siteFullUrl} requestDigest={requestDigest} />);
                            return;
                        }
                    } catch (error) {
                        console.warn(`Failed to fetch context from ${path}:`, error);
                        // Continue to next path
                    }
                }
                
                // If we get here, all context fetch attempts failed
                throw new Error('Could not fetch SharePoint context from any known endpoint');
            }
            
            tryFetchContext().catch(error => {
                console.error("Fatal Error: Could not initialize app.", error);
                const rootDiv = document.getElementById('root');
                rootDiv.innerHTML = `
                    <div class="p-4 bg-red-100 text-red-800 rounded">
                        <h3 class="font-bold">Fatal Error: Could not initialize app</h3>
                        <p class="mt-2">This utility requires SharePoint context. Please ensure you're running this from within a SharePoint site.</p>
                        <p class="mt-1 text-sm">Error details: ${error.message}</p>
                    </div>
                `;
            });
        }

        // Wait for the DOM to be fully loaded before starting the app
        if (document.readyState === 'complete' || document.readyState === 'interactive') {
            initializeAndStartApp();
        } else {
            document.addEventListener('DOMContentLoaded', initializeAndStartApp);
        }

    </script>

</body>
</html>
