({

    CreateRecord: function (component, event, helper) {
        var fileInput = component.find("file").getElement();
        console.log('number of files found = ' + fileInput.files.length);
        if(fileInput.files.length != 3) {
            alert('Incorrect amount of files, expected = 3, received is '+fileInput.files.length);
            return;
        }
        var Scholen = '';
        var scholengemeenschappen = '';
        var inrichtendeMachten = '';

        for(let i = 0; i < fileInput.files.length; i++) {
            console.log('### Looping, i = ' + i);
            let file = fileInput.files[i];
            let dataSort = file.name.substring(file.name.lastIndexOf(' ')+1,file.name.lastIndexOf('.'));
            console.log("### Datasort = " + dataSort);

            if (file) {
                    
                    if(dataSort == 'Scholen') {
                        console.log('Passing values of Scholen to JSON Parser.');
                        scholen = readFile(component, file);
                    } else if (dataSort == 'Scholengemeenschappen') {
                        console.log('Passing values of Scholengemeenschappen to JSON Parser.');
                        scholengemeenschappen = readFile(component, file);
                    } else if (dataSort == 'Inrichtende_machten') {
                        console.log('Passing values of Inrichtende Machten to JSON Parser.');
                        inrichtendeMachten = readFile(component, file);
                    } else {
                        alert('incorrect fileFormat found. Please make sure the fileformat is correct! Fileformat should be like "20201116 Scholen.txt" or "20201116 Scholengemeenschappen" or "20201116 Inrichtende_machten.txt"');
                        return;
                    }
                reader.onerror = function (evt) {
                console.log("error reading file");
                }
            }
        }
        console.log('########## Scholen = '+scholen);
        console.log('########## Scholengemeenschappen = '+scholengemeenschappen);
        console.log('########## inrichtendeMachten = '+inrichtendeMachten);
        alert('Starting the createAccount process');
        helper.CreateAccount(component,scholen,scholengemeenschappen,inrichtendeMachten);
    },

    readFile: function(component, file) {
        console.log('received file');

        var convertedFile;

        // filereader Object
        var objFilereader = new FileReader();
        objFilereader.onload = $A.getCallback(function(){
            var fileContents = objFilereader.result;
            convertedFile = helper.TXT2JSON(component, fileContents);
        });
        objFilereader.readAsText(file);

        return convertedFile;
    }
      
})