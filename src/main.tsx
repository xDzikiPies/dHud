import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { StatusProvider } from './contexts/StatusContext.tsx'
import { VehicleProvider } from './contexts/VehicleContext.tsx'
import { NuiProvider } from "fivem-nui-react-lib";

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <NuiProvider resource='dHud'>
      <StatusProvider>
        <VehicleProvider>
          <App />
        </VehicleProvider>
      </StatusProvider>
    </NuiProvider>
  </React.StrictMode>,
)
