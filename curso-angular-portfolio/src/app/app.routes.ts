import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'curso',
    title: 'Home da página',
    loadChildren: () =>
       import('./pages/curso.routes') .then((p) => p.cursoRoutes) 
  },
  {
    path: '**',
    loadComponent: () =>
         import('./pages/not-found/not-found.component'),
  },
];
