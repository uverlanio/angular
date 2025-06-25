import { Routes } from '@angular/router';
import { canActivateGuard } from 'app/guard/can-activate.guard';
import { canMatchGuard } from 'app/guard/can-match.guard';

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
    canMatch: [canMatchGuard] // serve para rotas single ou children com lazy load
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
