/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelas estrutura necessária para geração de picklist customizados
 *
 **************************************************************************************************************************************************************************/

public class CustomPickListOptionTO {
	public String label {get; set;}
	public String value {get; set;}
	public Boolean selected {get; set;}

	public CustomPickListOptionTO(String label, String value){
		this.label = label;
		this.value = value;
		this.selected = false;
	}
}