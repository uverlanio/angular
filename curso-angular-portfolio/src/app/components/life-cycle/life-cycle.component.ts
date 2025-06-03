import { CommonModule, JsonPipe } from '@angular/common';
import { AfterContentChecked, AfterContentInit, AfterViewChecked, AfterViewInit, ChangeDetectionStrategy, Component, ContentChild, DoCheck, ElementRef, Input, OnChanges, OnDestroy, OnInit, signal, SimpleChange, SimpleChanges, ViewChild } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormBuilder } from '@angular/forms';
import { timer } from 'rxjs';

@Component({
  selector: 'app-life-cycle',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './life-cycle.component.html',
  styleUrl: './life-cycle.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class LifeCycleComponent
  implements
    OnChanges,
    OnInit,
    DoCheck,
    AfterViewInit,
    AfterContentInit,
    AfterContentChecked,
    AfterViewChecked,
    OnDestroy
{
  public myNumber = signal(0);
  @Input() set inputMyNumber(value: number){
    this.myNumber.set(value);
  }
  public myText = signal('Uver');

  @ViewChild('content') public content!: ElementRef;
  @ContentChild('text') public text!: ElementRef;

  private _destroy$ = timer(0, 1000)
  .pipe(takeUntilDestroyed())
  .subscribe({
    next: (next) => console.log('next', next),
    error: (error) => console.log('error', error),
    complete: () => console.log('Complete!')
  });

  //Para injeção de dependência
  constructor(private fb: FormBuilder) {}

  ngOnChanges(changes: SimpleChanges): void {
    //if(changes['number'].previousValue === 2)
    //alert('ngOnChanges: ' + changes['number'].currentValue)
    //console.log('ngOnChanges');
  }

  ngOnInit(): void {
    //console.log('ngOnInit');
  }

  ngDoCheck(): void {
    //console.log('ngDoCheck');
  }

  ngAfterContentInit(): void {
    //console.log('ngAfterContentInit');
    //console.log(this.text.nativeElement.innerText);
  }

  ngAfterViewInit(): void {
    /*console.log('ngAfterViewInit');
    console.log(this.content.nativeElement.innerText);
    this.content.nativeElement.innerText = 'Lyfe Cycle 2';
    console.log(this.content.nativeElement.innerText);*/
  }

  ngAfterContentChecked(): void {
    //console.log('ngAfterContentChecked');
  }

  ngAfterViewChecked(): void {
    //console.log('ngAfterViewChecked');
  }

  ngOnDestroy(): void {
    console.log('ngOnDestroy')
    //this.destroy$.unsubscribe();
  }
}
