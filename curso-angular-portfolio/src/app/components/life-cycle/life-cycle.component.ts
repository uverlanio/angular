import { CommonModule, JsonPipe } from '@angular/common';
import { Component, Input, OnChanges, OnInit, SimpleChange, SimpleChanges } from '@angular/core';
import { FormBuilder } from '@angular/forms';

@Component({
  selector: 'app-life-cycle',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './life-cycle.component.html',
  styleUrl: './life-cycle.component.scss'
})
export class LifeCycleComponent implements OnChanges {

  @Input() public number = 0;

  //Para injeção de dependência
  constructor(private fb: FormBuilder){}

  

  ngOnChanges(changes: SimpleChanges): void {
    if(changes['number'].previousValue === 2)
      alert('ngOnChanges: ' + changes['number'].currentValue)
  }
}
