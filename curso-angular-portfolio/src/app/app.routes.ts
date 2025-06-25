import { Routes } from '@angular/router';
import { canActivateGuard } from './guard/can-activate.guard';
import { canActivateChildGuard } from './guard/can-activate-child.guard';

export const routes: Routes = [
  {
    path: 'curso',
    title: 'Home da página',
    loadChildren: () =>
       import('./pages/curso.routes').then((p) => p.cursoRoutes),
    canActivateChild: [canActivateChildGuard]
  },
  {
    path: '**',
    loadComponent: () =>
         import('./pages/not-found/not-found.component'),
  },
];
