export const ACS_CONFIG = {
  // Replace with your Azure Communication Services endpoint
  endpoint: import.meta.env.VITE_ACS_ENDPOINT || '',

  // Token endpoint - you'll need a backend service to generate tokens
  // NEVER expose your connection string in the client
  tokenEndpoint: import.meta.env.VITE_TOKEN_ENDPOINT || 'http://localhost:6969/tokens/create',
};

export const validateConfig = (): boolean => {
  if (!ACS_CONFIG.endpoint) {
    console.error('ACS endpoint is not configured. Set VITE_ACS_ENDPOINT in your .env file.');
    return false;
  }
  return true;
};
