import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    title: 'Home da página',
    loadComponent: () =>
         import('./pages/home/home.component'),
  },
  {
    path: 'sobre',
    title: 'Sobre da página',
    loadComponent: () =>
         import('./pages/sobre/sobre.component'),
  },
  {
    path: 'servicos/:id',
    loadComponent: () =>
         import('./pages/servicos-prestado/servicos-prestado.component'),
  },
  {
    path: '**',
    loadComponent: () =>
         import('./pages/not-found/not-found.component'),
  },
];
