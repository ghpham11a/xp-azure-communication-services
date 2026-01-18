/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_ACS_ENDPOINT: string;
  readonly VITE_TOKEN_ENDPOINT: string;
  readonly VITE_ACS_PHONE_NUMBER?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
