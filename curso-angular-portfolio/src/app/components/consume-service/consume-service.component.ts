import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
} from '@angular/core';
import { NewComponent } from 'app/modules/portfolio/components/new-component/new.component';
import { ApiService } from 'app/services/api.service';
import { timeInterval } from 'rxjs';

@Component({
  selector: 'app-consume-service',
  imports: [CommonModule, NewComponent],
  standalone: true,
  templateUrl: './consume-service.component.html',
  styleUrl: './consume-service.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConsumeServiceComponent implements OnInit {
  //#apiService = inject(ApiService)
  constructor(private _apiService: ApiService) {}

  ngOnInit(): void {
    console.log(this._apiService.name());

    this._apiService.name$.subscribe({
      next: (next) => console.log(next),
      error: (error) => console.log(error),
      complete: () => console.log('Complete!'),
    
    })

    this._apiService.name.set('Uver $$')

    setTimeout(() => {
      console.log(this._apiService.name())
    },
    2000)
  }
}
