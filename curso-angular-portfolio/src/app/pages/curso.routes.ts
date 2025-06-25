import { Routes } from '@angular/router';

export const cursoRoutes: Routes = [
  {
    path: '',
    title: 'Home da página',
    loadComponent: () =>
         import('./home/home.component'),
  },
  {
    path: 'sobre',
    title: 'Sobre da página',
    loadComponent: () =>
         import('./sobre/sobre.component'),
  },
  {
    path: 'servicos/:id',
    loadComponent: () =>
         import('./servicos-prestado/servicos-prestado.component'),
  },
  {
    path: '**',
    loadComponent: () =>
         import('./not-found/not-found.component'),
  },
];
