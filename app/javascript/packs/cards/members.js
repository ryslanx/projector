window.assignClickHandler = function(event) {
  const token = $('meta[name="csrf-token"]').attr('content');
  var boardId = $('.card').data('board-id');
  var columnId = $(this).closest('.kanban-board').data('column-id');
  var cardId = $(this).parents('.kanban-item').data('card-id');
  Swal.fire({
    title: 'Assign User',
    input: 'text',
    confirmButtonClass: 'btn btn-primary',
    buttonsStyling: false,
    inputAttributes: {
      autocapitalize: 'off',
      id: 'members-input',
      style: 'display: flex;margin-bottom: 0px;'
    },
    showCancelButton: true,
    confirmButtonText: 'Assign',
    showLoaderOnConfirm: true,
    cancelButtonClass: "btn btn-danger ml-1",
    preConfirm: function (email) {
      return fetch(`/boards/${boardId}/columns/${columnId}/cards/${cardId}/add_assignee`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': token
          },
          body: `{"email": "${email}"}`
        })
        .then((response) => {
          if (response.ok) {
            $(`#card-${cardId}`).load(` #card-${cardId}`);
          }
          return response.json()
        })
        .catch(function (error) {
          Swal.showValidationMessage(
            "Request failed:  " + error + ""
          )
        })
    },
    allowOutsideClick: function () {
      !Swal.isLoading()
    }
  }).then(function (result) {
    console.log(result);
    if (result.value.error) {
      Swal.fire({
        title: result.value.error,
        type: "error",
        confirmButtonClass: 'btn btn-primary',
        buttonsStyling: false,
      });
    } else {
      Swal.fire({
        title: "User assigned!",
        type: "success",
        confirmButtonClass: 'btn btn-primary',
        buttonsStyling: false,
      });
    }
  })

    const membersAutoComplete = new autoComplete({
      data: {
        src: async () => {
          const query = document.querySelector("#members-input").value;
          const source = await fetch(window.location.href + `/members.json?search=${query}`);
          const data = await source.json();
          return data;
        },
        key: ["email"],
        cache: false
      },
      sort: (a, b) => {
        if (a.match < b.match) return -1;
        if (a.match > b.match) return 1;
        return 0;
      },
      placeHolder: "Find members",
      selector: "#members-input",
      debounce: 300,
      searchEngine: "strict",
      resultsList: {
        render: true,
        container: source => {
          source.setAttribute("id", "members_list");
          source.setAttribute("style", "padding-left: 0px;");
        },
        destination: document.querySelector("#members-input"),
        position: "afterend",
        element: "ul"
      },
      maxResults: 5,
      highlight: true,
      resultItem: {
        content: (data, source) => {
          source.setAttribute("class", "list-group-item list-group-item-action");
          source.setAttribute("style", "cursor: pointer;");
          source.innerHTML = `<span> ${data.value.email} </span>`
          const userData = document.createElement("span");
          source.appendChild(userData);
        },
        element: "li"
      },
      noResults: () => {
        const result = document.createElement("li");
        result.setAttribute("class", "no_result list-group-item list-group-item-action");
        result.setAttribute("tabindex", "1");
        result.innerHTML = "No Results";
        document.querySelector("#members_list").appendChild(result);
      },
      onSelection: (target) => {
          $('#members-input').val(target.selection.value.email);
      }
    });
  event.preventDefault();
  event.stopPropagation();
}


$(() => {
  $('.members-request').click(assignClickHandler);
});
