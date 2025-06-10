import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { NewComponent } from 'app/modules/portfolio/components/new-component/new.component';
import { ApiService } from 'app/services/api.service';
import { Observable, timeInterval } from 'rxjs';

@Component({
  selector: 'app-consume-service',
  imports: [CommonModule, NewComponent],
  standalone: true,
  templateUrl: './consume-service.component.html',
  styleUrl: './consume-service.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})

export class ConsumeServiceComponent implements OnInit {

  public getTask = signal<null | Array<{
    id : string,
    title : string
  }>>(null);

  public getTask$: Observable<Array<{
    id : string,
    title : string
  }>>;

  //#apiService = inject(ApiService)
  constructor(private _apiService: ApiService) {
    this.getTask$ = this._apiService.httpListTask$();
  }

  ngOnInit(): void {
    this.getTask$.subscribe({
      next: (next: { id: string; title: string; }[] | null) => {
        this.getTask.set(next)
        console.log(next)},
      error: (error: any) => console.log(error),
      complete: () => console.log('Complete!')
    })
  }
}
