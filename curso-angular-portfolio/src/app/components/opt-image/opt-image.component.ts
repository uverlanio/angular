import { NgOptimizedImage } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-opt-image',
  imports: [NgOptimizedImage],
  standalone: true,
  templateUrl: './opt-image.component.html',
  styleUrl: './opt-image.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class OptImageComponent {

}
