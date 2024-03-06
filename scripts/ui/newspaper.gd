@tool
extends Node3D
class_name Newspaper

@export_category("Newspaper")
@export var page_index: int:
	get: return _page_index
	set(value):
		_page_index = clamp(value, 0, pages.size() - 1)
		flip_to(page_index)

var pages: Array[NewspaperPage] = []
var _page_index := 0
var current_page_index := 0
var current_page: NewspaperPage:
	get: return pages[current_page_index]
var previous_page_index := 0

func _ready():
	for child in get_children():
		if child is NewspaperPage:
			child.enabled = false
			pages.append(child)
	if not pages.is_empty():
		current_page.enabled = true
	if not child_entered_tree.is_connected(add_page):
		child_entered_tree.connect(add_page)
	if not child_exiting_tree.is_connected(remove_page):
		child_exiting_tree.connect(remove_page)

func previous_page():
	page_index = previous_page_index

func first_page():
	page_index = 0

func last_page():
	page_index = pages.size() - 1

func flip_to(index: int):
	if index == current_page_index:
		return
	
	if index > current_page_index:
		var previous_page: NewspaperPage = null
		for i in range(current_page_index, index):
			pages[i].go_back_enabled = false
			pages[i].enabled = false
			if previous_page == null:
				pages[i].open()
			else:
				previous_page.opened.connect(func(): pages[i].open(), CONNECT_ONE_SHOT)
			previous_page = pages[i]
	else:
		var previous_page: NewspaperPage = null
		for i in range(current_page_index - 1, index - 1, -1):
			pages[i].go_back_enabled = false
			pages[i].enabled = false
			if previous_page == null:
				pages[i].close()
			else:
				previous_page.closed.connect(func(): pages[i].close(), CONNECT_ONE_SHOT)
			previous_page = pages[i]
	previous_page_index = current_page_index
	_page_index = index
	current_page_index = index
	current_page.enabled = true
	if index > 0:
		pages[index - 1].go_back_enabled = true

func add_page(node: Node3D):
	if node is NewspaperPage and node not in pages:
		pages.append(node)

func remove_page(node: Node3D):
	if node is NewspaperPage and node in pages:
		pages.remove_at(pages.find(node))
