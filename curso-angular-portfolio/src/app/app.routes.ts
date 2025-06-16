import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home.component';
import { SobreComponent } from './pages/sobre/sobre.component';
import { ServicosPrestadoComponent } from './pages/servicos-prestado/servicos-prestado.component';


export const routes: Routes = [
    {
        path: '',
        title: 'Home da página',
        component: HomeComponent
    },
    {
        path: 'sobre',
        title: 'Sobre da página',
        component: SobreComponent
    },
    {
        path: 'servicos/:id',
        component: ServicosPrestadoComponent
    }
];
