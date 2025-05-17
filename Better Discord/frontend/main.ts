import { app, BrowserWindow } from 'electron';
import * as path from 'path';

let mainWindow: BrowserWindow | null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,    // keep it secure
      contextIsolation: true,    // recommended for security
      preload: path.join(__dirname, 'preload.js'), // if you have one; else omit
    },
  });

  // Load React app in dev or production mode:
  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:3000');  // Vite dev server URL
  } else {
    mainWindow.loadFile(path.join(__dirname, '../build/index.html')); // built static files
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (mainWindow === null) createWindow();
});
