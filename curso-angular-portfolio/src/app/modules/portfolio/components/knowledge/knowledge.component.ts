import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { IKnowledge } from '../../interface/IKnowledge.interface';

@Component({
  selector: 'app-knowledge',
  standalone: true,
  imports: [],
  templateUrl: './knowledge.component.html',
  styleUrl: './knowledge.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class KnowledgeComponent {
  public arrayKnowledge = signal<IKnowledge[]>([
    {
      src: 'assets/icons/knowledge/css3.svg',
      alt: ' Ícone de conhecimento de css3'
    },
    {
      src: 'assets/icons/knowledge/angular.svg',
      alt: ' Ícone de conhecimento de angular'
    },
    {
      src: 'assets/icons/knowledge/java.svg',
      alt: ' Ícone de conhecimento de java'
    },
    {
      src: 'assets/icons/knowledge/javascript.svg',
      alt: ' Ícone de conhecimento de javascript'
    },
    {
      src: 'assets/icons/knowledge/sass.svg',
      alt: ' Ícone de conhecimento de sass'
    }
  ])

}
