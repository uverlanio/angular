/** Classe de entidade do JSON dos serviços docusign
 * @historia PLV-4635
 * @author Guilherme Azevedo
 * @version 1.0
*/
//PLV-4635 INICIO
public class DocusignServiceEntity {
    
    public String id_salesforce;
    public DocuSignEnvelopeInformation DocuSignEnvelopeInformation;

    //++++++++++++++++++++++++
    // ENTITY CLASSES
    //++++++++++++++++++++++++

	public class DocuSignEnvelopeInformation {

		public String xmlns_xsd;
		public String xmlns;
		public String TimeZone;
		public DocumentPDFs DocumentPDFs;
		public EnvelopeStatus EnvelopeStatus;
		public String xmlns_xsi;
		public String TimeZoneOffset;
	}

	public class DocumentPDFs {

        public List<DocumentPDF> DocumentPDF;
	}

	public class EnvelopeStatus {

		public String Email;
		public Boolean AuthoritativeCopy;
		public String ACHolderLocation;
		public String ACStatusDate;
		public String SigningLocation;
		public RecipientStatuses RecipientStatuses;
		public String Created;
		public String ACHolderEmail;
		public DocumentStatuses DocumentStatuses;
		public String ACStatus;
		public String Sent;
		public String Status;
		public Boolean EnvelopeIdStamping;
		public String TimeGenerated;
		public String UserName;
		public String EnvelopeID;
		public String Delivered;
		public String Signed;
		public String Subject;
		public String SenderIPAddress;
		public String EnvelopePDFHash;
		public Boolean AutoNavigation;
		public CustomFields CustomFields;
		public String ACHolder;
		public String Completed;
	}

	public class DocumentPDF {
        
		public String DocumentID;
		public String DocumentType;
		public String PDFBytes;
		public String Name;
	}

	public class RecipientStatus {
        
		public String Status;
		public String Email;
		public String UserName;
		public String RecipientId;
		public String Delivered;
		public String Signed;
		public TabStatuses TabStatuses;
		public String AccountStatus;
		public String Type;
		public String CustomFields;
		public String RecipientIPAddress;
		public String RoutingOrder;
		public DeclineReason DeclineReason;
		public String Sent;
	}

	public class RecipientStatuses {

		public RecipientStatus RecipientStatus;
	}

	public class TabStatuses {

		public TabStatus TabStatus;
	}

	public class DocumentStatus {

		public String TemplateName;
		public String ID;
		public String Sequence;
		public String Name;
	}

	public class DocumentStatuses {

		public DocumentStatus DocumentStatus;
	}

	public class CustomFields {

		public List<CustomField> CustomField;
	}

	public class CustomField {

		public Boolean Required;
		public String Value;
		public Boolean Show;
		public String CustomFieldType;
		public String Name;
	}

	public class DeclineReason {

		public Boolean xsi_nil;
	}

	public class TabStatus {

		public String Status;
		public String TabType;
		public String XPosition;
		public String YPosition;
		public String PageNumber;
		public String DocumentID;
		public String TabLabel;
		public String TabName;
    }
    //PLV-4635 FIM
}