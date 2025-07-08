import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, signal } from '@angular/core';

@Component({
  selector: 'app-animations',
  imports: [CommonModule],
  templateUrl: './animations.component.html',
  styleUrl: './animations.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('move-ball', [
      
    ])
  ]
})
export class AnimationsComponent {

  public moveIn = signal('');
}
function trigger(arg0: string, arg1: never[]): any {
  throw new Error('Function not implemented.');
}

