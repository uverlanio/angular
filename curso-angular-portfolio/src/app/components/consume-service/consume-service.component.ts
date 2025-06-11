import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { NewComponent } from 'app/modules/portfolio/components/new-component/new.component';
import { ApiService } from 'app/services/api.service';
import { concatMap, Observable, timeInterval } from 'rxjs';

@Component({
  selector: 'app-consume-service',
  imports: [CommonModule, NewComponent],
  standalone: true,
  templateUrl: './consume-service.component.html',
  styleUrl: './consume-service.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})

export class ConsumeServiceComponent implements OnInit {

  #apiService = inject(ApiService);
  public getListTask = this.#apiService.getListTask;
  public getTaskId = this.#apiService.getTaskId;

  ngOnInit(): void {
    this.#apiService.httpListTask$().subscribe();
  }


  public httpTaskCreate(title: string){
    return this.#apiService
      .httpTaskCreate$(title)
      .pipe(concatMap(() => this.#apiService.httpListTask$()))
      .subscribe();
  }
}
