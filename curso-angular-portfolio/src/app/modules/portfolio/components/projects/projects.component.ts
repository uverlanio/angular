import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { IProjects } from '../../interface/IProjects.interface';
//Material
import {MatDialog, MatDialogModule} from '@angular/material/dialog';
import { EDialogPanelClass } from '../../enum/EDialogPanelClass.enum';
import { DialogProjectsComponent } from '../dialog/dialog-projects/dialog-projects.component';

@Component({
  selector: 'app-projects',
  standalone: true,
  imports: [MatDialogModule],
  templateUrl: './projects.component.html',
  styleUrl: './projects.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProjectsComponent {
  #dialog = inject(MatDialog);
  public arrayProjects = signal<IProjects[]>([
    {
      src: 'assets/img/projects/vfull.png',
      alt: 'Projeto Vida FullStack',
      title: 'Vida FullStack',
      width: '100px',
      height: '51px',
      description: '<p>Explore o fascinante mundo do desenvolvimento web e descubra como ideias se transformam em experiências digitais incríveis. Mergulhe em linguagens, frameworks e ferramentas que moldam os sites e aplicativos que usamos todos os dias. Aprenda, crie e inove enquanto desenvolve projetos que conectam pessoas e tecnologias no universo online.</p>',
      links: [
        {
          name: 'Conheça o Blog',
          href: 'https://vidafullstack.com.br'
        }
      ]
    },
    {
      src: 'assets/img/projects/vfull.png',
      alt: 'Projeto Vida FullStack',
      title: 'Vida FullStack',
      width: '100px',
      height: '51px',
      description: '<p>Explore o fascinante mundo do desenvolvimento web e descubra como ideias se transformam em experiências digitais incríveis. Mergulhe em linguagens, frameworks e ferramentas que moldam os sites e aplicativos que usamos todos os dias. Aprenda, crie e inove enquanto desenvolve projetos que conectam pessoas e tecnologias no universo online.</p>',
      links: [
        {
          name: 'Conheça o Blog',
          href: 'https://vidafullstack.com.br'
        }
      ]
    },
    {
      src: 'assets/img/projects/vfull.png',
      alt: 'Projeto Vida FullStack',
      title: 'Vida FullStack',
      width: '100px',
      height: '51px',
      description: '<p>Explore o fascinante mundo do desenvolvimento web e descubra como ideias se transformam em experiências digitais incríveis. Mergulhe em linguagens, frameworks e ferramentas que moldam os sites e aplicativos que usamos todos os dias. Aprenda, crie e inove enquanto desenvolve projetos que conectam pessoas e tecnologias no universo online.</p>',
      links: [
        {
          name: 'Conheça o Blog',
          href: 'https://vidafullstack.com.br'
        }
      ]
    }
  ])

  public openDialog(data: IProjects){
    this.#dialog.open(DialogProjectsComponent,{
      data,
      panelClass: EDialogPanelClass.PROJECTS
    })
  }
}
